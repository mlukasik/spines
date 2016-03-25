'''
Generates CSV files with all features values of spines (at all 3 timestamps), divided by groups.
'''
from utils import for_each_spine_triple, parse_excel_on_spines, find_group_animals_from_catalogue, nencki_feature_names, HEADER_DATA_3STAMPS
from gen_csv_data_params import *

def write_all_data_table(fname1, fname2, fname3, fwrite, identification, animal_id,
                         group_id, relative = False):
    ''' 
    Stores all spines from fname1, fname2 and fname3, with features taken from all 3 timestamps.  
    
    Returns next not used identification number - this way, we don't have to know a priori,
        how many spines there are in one file.
    '''
    for spine_id, features1, features2, features3 in for_each_spine_triple(fname1, fname2, fname3):
        spine_id = "%.3d" % float(spine_id)
        animal_id = "%.3d" % float(animal_id)
        #print spine_id, animal_id
        fwrite.write(" ".join(map(str, ["00-"+str(animal_id)+"-"+str(spine_id)+"-"+group_id, spine_id, animal_id, group_id] + 
                                  map(lambda x: x.split("/")[-1], [fname1.replace(" ", ""), fname2.replace(" ", ""), fname3.replace(" ", "")]) +
                                  features1+features2+features3))+"\n")
        identification += 1
    return identification
if __name__ == "__main__":
    if load_groups_animals_info_from_excel:
        groups, animals = parse_excel_on_spines(excel)
    else:
        #print "=========================================================="
        groups, animals = find_group_animals_from_catalogue(PREFIX)
    print "animals:", animals
    print "groups:", groups
    
    if not separate_files:
        fwrite = open(res_path+"ALL_triple.txt", 'w')
        feature_header = HEADER_DATA_3STAMPS#map(lambda x: group_id0+'_'+x, nencki_feature_names[1:])
        fwrite.write(" ".join(feature_header)+"\n")
        
    for group_id, animal_ids in groups.iteritems():
        if separate_files:
            fwrite = open(res_path+group_id+"_triple.txt", 'w')
            feature_header = HEADER_DATA_3STAMPS#map(lambda x: group_id0+'_'+x, nencki_feature_names[1:])
            fwrite.write(" ".join(feature_header)+"\n")
        
        #gather differences from animals:
        identification = 0
        for animal_id in animal_ids:
            identification = write_all_data_table(inp_catalogue+\
                                        animals[animal_id][group_id0], 
                                    inp_catalogue+\
                                        animals[animal_id][group_id1], 
                                    inp_catalogue+\
                                        animals[animal_id][group_id2],  
                                         fwrite, identification, animal_id,
                                         group2letter[group_id],
                                         relative=exlude_not_divisible)