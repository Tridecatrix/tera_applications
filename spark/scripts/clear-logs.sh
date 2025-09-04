# NOTE: BE VERY CAREFUL WITH THIS!

for f in ~/tera_applications/spark/spark-3.3.0/logs/*; do
    echo "Removing: $f"
    rm "$f"
done

for d in ~/tera_applications/spark/spark-3.3.0/work/*; do
    echo "Removing: $d"
    rm -r "$d"
done