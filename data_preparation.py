import logging
from grids import GeohashGrid, H3Grid
from speciesgrids import DatasetBuilder
import pyarrow.parquet as pq
import os
import pyarrow.compute as pc
import pyarrow as pa
import shutil


logger = logging.getLogger(__name__)
logging.basicConfig(format="%(asctime)s %(message)s", level=logging.INFO)


# split

batch_size = 1000000
parquet_path = "data/obis_20231025.parquet"
output_dir = "data/obis_20231025"

parquet_file = pq.ParquetFile(parquet_path)

if os.path.exists(output_dir) and os.path.isdir(output_dir):
    shutil.rmtree(output_dir)
os.makedirs(output_dir, exist_ok=False)

i = 0
for batch in parquet_file.iter_batches(batch_size=batch_size):

    writer = pq.ParquetWriter(os.path.join(output_dir, f"{i}.parquet"), batch.schema)
    writer.write_batch(batch)
    print(f"Written batch {i}")
    writer.close()
    i = i + 1


# build dataset

datasets = [
    ["data/obis_20231025", "data/h3_4_20231025_0_200", "data/temp_h3_4_20231025_0_200", ["depth <= 200"]],
    ["data/obis_20231025", "data/h3_4_20231025_200_3000", "data/temp_h3_4_20231025_200_3000", ["depth > 200", "depth <= 3000"]],
    ["data/obis_20231025", "data/h3_4_20231025_3000_6000", "data/temp_h3_4_20231025_3000_6000", ["depth > 3000", "depth <= 6000"]]
]

for dataset in datasets:

    logging.info(dataset)

    builder = DatasetBuilder(
        sources={
            "obis": dataset[0],
        },
        grid=H3Grid(4, 3),
        quadkey_level=3,
        output_path=dataset[1],
        worms_taxon_path="data/worms/WoRMS_OBIS/taxon.txt",
        worms_matching_path="data/worms/match-dataset-2011.tsv",
        worms_profile_path="data/worms/WoRMS_OBIS/speciesprofile.txt",
        worms_redlist_path="data/worms/redlist.parquet",
        worms_output_path="data/worms/worms_mapping.parquet",
        temp_path=dataset[2],
        predicates=dataset[3],
        species=False
    )
    builder.build(worms=False, index=True, merge=True)
