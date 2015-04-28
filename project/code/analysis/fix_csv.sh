# trying to fix stray quotes in csv files
#grep -e '\([^,\]\)\("\)\([^,]\)' ../../data/American_Pale_Ale_\(APA\)/1199_4073 -n

FILE=../../data/American_Pale_Ale_\(APA\)/1199_4073

cp $FILE $FILE.bak

sed -e 's/\([^,\]\)\("\)\([^,]\)/\1""\3/g' $FILE -i