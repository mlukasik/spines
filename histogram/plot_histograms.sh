for feature in 'length' 'head_width' 'max_width_location' 'max_width' 'width_length_ratio' 'length_width_ratio' 'neck_width' 'foot' 'circumference' 'area' 'length_area_ratio'
do
    python breaking_points_relative.py $feature
done
