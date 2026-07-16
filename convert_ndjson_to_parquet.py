import sys
import duckdb

ndjson_path = sys.argv[1]
parquet_path = sys.argv[2]


con = duckdb.connect()

con.sql(f"SELECT * FROM read_json_auto('{ndjson_path}', maximum_object_size=1000000000)")
con.sql(f"COPY (SELECT * FROM read_json_auto('{ndjson_path}')) TO '{parquet_path}' (FORMAT 'parquet')")
print(f"Wrote {parquet_path}")