library(zip)
library(aws.s3)

zip(zipfile = "archive.zip", files = list.files(".", full.names = FALSE), root = "data")
put_object(file = "data/archive.zip", object = "sampling-effort-depth/archive.zip", bucket = "obis-products")
file.remove("data/archive.zip")
