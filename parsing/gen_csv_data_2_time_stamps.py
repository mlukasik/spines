'''
Generates CSV files with all features values of spines (at starting moment 
and at stopping moment), divided by groups.
'''
from utils import for_each_spine_pair, parse_excel_on_spines, HEADER_DATA_2STAMPS
from gen_csv_data_params import *

def write_all_data_table(fname1, fname2, fwrite, identification, animal_id,
                         group_id, relative = False):
    ''' 
    Pairs spines from fname1 and fname2 (each spine occurs once in fname1 and
    fname2). Matching is done by id.
    To a passed fwrite, write a spine id and list of features.
    '''
    
    for spine_id, features_prev, features_after in for_each_spine_pair(fname1, fname2):
        #print spine_id
        spine_id = "%.3d" % float(spine_id)
        animal_id = "%.3d" % float(animal_id)
        fwrite.write(" ".join(map(str, ["00-"+str(animal_id)+"-"+str(spine_id)+"-"+group_id, spine_id, animal_id, group_id] + 
                                  map(lambda x: x.split("/")[-1], [fname1.replace(" ", ""), fname2.replace(" ", "")]) +
                                  features_prev+features_after))+"\n")
        #fwrite.write(" ".join(map(str, [spine_id] + features_prev + features_after))+"\n")    
if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2:
        print "First argument: excel file"
        exit(1)
    excel = sys.argv[1]
    if len(sys.argv) < 3:
        print "Second argument: catalogue with csv files"
        exit(1)
    inp_catalogue = sys.argv[2]
    if len(sys.argv) < 4:
        print "3d argument: catalogue where to store results"
        exit(1)
    res_catalogue = sys.argv[3]
    if len(sys.argv) < 5:
        print "4th argument: Group_id from"
        exit(1)
    from_id = sys.argv[4]
    if len(sys.argv) < 6:
        print "5th argument: Group_id to"
        exit(1)
    to_id = sys.argv[5]
    
    groups, animals = parse_excel_on_spines(excel)
    if not separate_files:
        fwrite = open(res_path+"ALL_triple.txt", 'w')
        feature_header = HEADER_DATA_2STAMPS#map(lambda x: group_id0+'_'+x, nencki_feature_names[1:])
        fwrite.write(" ".join(feature_header)+"\n")
        
    for group_id, animal_ids in groups.iteritems():
        if separate_files:
            fwrite = open(res_path+group_id+"_triple.txt", 'w')
            feature_header = HEADER_DATA_2STAMPS#map(lambda x: group_id0+'_'+x, nencki_feature_names[1:])
            fwrite.write(" ".join(feature_header)+"\n")
    print "animals:", animals
    for group_id, animal_ids in groups.iteritems():
        print group_id
        
        identification = 0
        for animal_id in animal_ids:
            write_all_data_table(inp_catalogue+\
                                        animals[animal_id][from_id], 
                                    inp_catalogue+\
                                        animals[animal_id][to_id], 
                                         fwrite, identification, animal_id,
                                         group2letter[group_id],
                                         relative=exlude_not_divisible)