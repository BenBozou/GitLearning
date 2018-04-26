git log --name-only --pretty=format: master --not origin/master >> ./file_list.txt
#xargs -I{} < file_list.txt  cp -v {} ./src_to_deploy/


for file in $(cat ./file_list.txt); do
    echo "checking for $file"
    if [[ -f "$file" ]]; then
        file_folder=$(dirname "$file")
        destination_folder=./src_to_deploy/${file_folder#/root/}
        echo "copying file $file to $destination_folder"
        mkdir -p "$destination_folder"
        cp "$file" "$destination_folder"
    fi
done

sgp -s ./src_to_deploy -a 40.0 -o ./
rm file_list.txt