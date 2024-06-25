# sampling-effort-depth

This repo contains script to generated hexagonal grids of sampling effort (number of OBIS records) by depth layer. The data files and figures are available from <https://obis-products.s3.amazonaws.com/sampling-effort-depth/archive.zip>.

## Data preparation

Occurrence data from OBIS is gridded using the [speciesgrids](https://github.com/iobis/speciesgrids) Python package. See <data_preparation.py>.

## Figures

Figures are are generated in <figures.R>.
