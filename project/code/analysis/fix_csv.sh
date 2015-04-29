# trying to fix stray quotes in csv files
#grep -e '\([^,\]\)\("\)\([^,]\)' ../../data/American_Pale_Ale_\(APA\)/1199_4073 -n

#FILE=../../data/American_Pale_Ale_\(APA\)/1199_4073
#FILE=../../data/American_Double__Imperial_Stout/394_20539

#cp $FILE $FILE.bak

for FILE in `find ../../data/ -type f`;
do
    sed -e 's/\([^,\]\)\("\)\([^,]\)/\1""\3/g' $FILE -i
done