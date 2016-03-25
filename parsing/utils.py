#This is old data row, now it has been extended:
#feature names for data from NENCKI:
#nencki_feature_names = ['spine_id', 'length','head_width', 'max_width_location', 
#'max_width', 'width_length_ratio', 'length_width_ratio', 'neck_width', 'foot',
#'circumference', 'area', 'length_area_ratio']

#nencki_feature_names_noid = ['length','head_width', 'max_width_location', 
#'max_width', 'width_length_ratio', 'length_width_ratio', 'neck_width', 'foot',
#'circumference', 'area', 'length_area_ratio']

nencki_feature_names_distance_calculation = ['length','head_width', 'max_width_location', 
'max_width', 'width_length_ratio', 'length_width_ratio', 'neck_width', 'foot',
'circumference', 'area', 'length_area_ratio']

nencki_feature_names = ['spine_id', 'length', 'head_width', 'max_width_location', 'max_width',
                        'width_length_ratio', 'length_width_ratio', 'neck_width', 'foot',
                        'circumference', 'area', 'length_area_ratio', 'mean_brightness',
                        'x_m', 'y_m', 'mean_brightness_GREEN', 'mean_brightness_BLUE',
                        'mean_brightness_top_GREEN', 'mean_brightness_top_BLUE',
                        'mean_brightness_bottom_GREEN', 'mean_brightness_bottom_BLUE',
                        'membrane_brightness_GREEN', 'membrane_brightness_BLUE',
                        'BCKG_sub_brght_GREEN', 'BCKG_sub_brght_BLUE', 'in_spine_pearson']

nencki_feature_names_noid = ['length', 'head_width', 'max_width_location', 'max_width',
                        'width_length_ratio', 'length_width_ratio', 'neck_width', 'foot',
                        'circumference', 'area', 'length_area_ratio', 'mean_brightness',
                        'x_m', 'y_m', 'mean_brightness_GREEN', 'mean_brightness_BLUE',
                        'mean_brightness_top_GREEN', 'mean_brightness_top_BLUE',
                        'mean_brightness_bottom_GREEN', 'mean_brightness_bottom_BLUE',
                        'membrane_brightness_GREEN', 'membrane_brightness_BLUE',
                        'BCKG_sub_brght_GREEN', 'BCKG_sub_brght_BLUE', 'in_spine_pearson']

nencki_feature_names_for_ttest_comparison = ['length', 'head_width', 'max_width_location', 'max_width',
                        'width_length_ratio', 'length_width_ratio', 'neck_width', 'foot',
                        'circumference', 'area', 'length_area_ratio']

#how many leading features about id there are in HEADER_DATA_3STAMPS:
ID_COUNT = 3
HEADER_DATA_3STAMPS = ['unique_id', 'nencki_id', 'animal_id', 'group_id', "source0", "source10", "source40"]+\
    map(lambda x: '0MIN_'+x, nencki_feature_names_noid)+\
    map(lambda x: '10_MIN_'+x, nencki_feature_names_noid)+\
    map(lambda x: '40_MIN_'+x, nencki_feature_names_noid) 

HEADER_DATA_2STAMPS = ['unique_id', 'nencki_id', 'animal_id', 'group_id', "source0", "source10"]+\
    map(lambda x: '0MIN_'+x, nencki_feature_names_noid)+\
    map(lambda x: '10_MIN_'+x, nencki_feature_names_noid)

TIME_STAMPS = ['0MIN', '10_MIN', '40_MIN']
T0MINFEATURES  = list(f for f in sorted(HEADER_DATA_3STAMPS) if f.startswith("0MIN")  )
T10MINFEATURES = list(f for f in sorted(HEADER_DATA_3STAMPS) if f.startswith("10_MIN")  ) 
T40MINFEATURES = list(f for f in sorted(HEADER_DATA_3STAMPS) if f.startswith("40_MIN")  )  
ALLFEATURES = T0MINFEATURES + T10MINFEATURES + T40MINFEATURES

T0MINFEATURESDISTANCE = list(f for f in sorted(HEADER_DATA_3STAMPS) if f.startswith("0MIN") and any(map(lambda x: x in f, nencki_feature_names_distance_calculation)))

UQID = "unique_id" 

HEADER_LINES = 16

#############################################################################################

#p-values for each feature calculated using R;
#Kolmogorov-Smirnov test for difference between distributions of Forskolin
#and DMSO
pvalues_diff_DMSO_FORSKOLIN = [0.0002981082, 0.0073448533, 0.0183883878, 
                            0.0005254203, 0.0007537101, 0.0007537101, 
                            0.0016028076, 0.0013691250, 0.1778090910, 
                            0.7755043225, 0.0016534920]
FNAMES_FOR_pvalues =  [  '40_MIN_length',
                         '40_MIN_head_width',
                         '40_MIN_max_width_location',
                         '40_MIN_max_width',
                         '40_MIN_width_length_ratio',
                         '40_MIN_length_width_ratio',
                         '40_MIN_neck_width',
                         '40_MIN_foot',
                         '40_MIN_circumference',
                         '40_MIN_area',
                         '40_MIN_length_area_ratio']


def time0_features_inds_distance():
    '''
    Yield indices of features at time 0, relevant for feature calculation.
    '''
    for feature in T0MINFEATURESDISTANCE:
        yield HEADER_DATA_3STAMPS.index(feature)

#############################################################################################

def parse_excel_on_spines(excel):
    '''
    Extracts information from excel file given by Nencki.
    
    Returns:
     Groups - maps group_id to set of animal id (each animal is in single file
     and is represented by its spines)
     animals - maps animal_id sub_group_id to file name where information is 
     stored about given animal in given time
    '''
    import xlrd
    sh = xlrd.open_workbook(excel).sheet_by_index(0)
    groups = {}
    animals = {}
    #for each row of excel file:
    for row_num in xrange(1, sh.nrows):
        #read that row:
        (storage_file, file_name, scale, ID_0, ID_1, Version, Experiment_Name, 
        Animal_Type, Animal_ID, group_id, Subgroup_1_ID, Subgroup_2_ID, 
        Picture_Nr, Brain_Region, Dendrite_Rank, Notes, 
        Marked_Dendrite_Length) \
        = sh.row_values(row_num)
        #print (storage_file, file_name, scale, ID_0, ID_1, Version, Experiment_Name, 
        #Animal_Type, Animal_ID, group_id, Subgroup_1_ID, Subgroup_2_ID, 
        #Picture_Nr, Brain_Region, Dendrite_Rank, Notes, 
        #Marked_Dendrite_Length)
        #extract filename of storage file:
        storage_file = storage_file.split('\\')[-1]
        #update animals in a given group:
        groups[group_id] = groups.get(group_id, set()) | set([Animal_ID])
        if Animal_ID not in animals:
            animals[Animal_ID] = {}
        #in the file there are some floats which are not relevant
        #if type(Subgroup_1_ID) == str or type(Subgroup_1_ID) == unicode: 
        animals[Animal_ID][Subgroup_1_ID] = storage_file
    return groups, animals


import os
def find_group_animals_from_catalogue(cat, filename_filter=lambda x: x.endswith(".csv")):
    '''
    Extracts information from catalogue with files given by Nencki.
    
    Returns:
     Groups - maps group_id to set of animal id (each animal is in single file
     and is represented by its spines)
     animals - maps animal_id sub_group_id to file name where information is 
     stored about given animal in given time
    '''
    groups = {}
    animals = {}
    for fname in os.listdir(cat):
        if filename_filter(fname):
            File_name, Scale, ID_0, ID_1, Version, Experiment_Name, \
            Animal_Type, Animal_ID, Group_ID, Subgroup_1_ID, Subgroup_2_ID, \
            Picture_Nr, Brain_Region, Dendrite_Rank, Notes, \
            Marked_Dendrite_Length = parse_spines_csv_header(os.path.join(cat, fname))
            
            #if Group_ID in ["CONTROLTEST_DMSO", "FORSKOLIN", "CONTROL_D", "CONTROL"] and Experiment_Name=="FORSKOLIN":
            #postprocess
            if Group_ID=="CONTROL_D":
                Group_ID = "CONTROLTEST_DMSO"
                Subgroup_1_ID = "0MIN"
                
            if Group_ID=="CONTROL":
                Group_ID = "FORSKOLIN"
                Subgroup_1_ID = "0MIN"
                
            if Subgroup_1_ID=='10MIN':
                Subgroup_1_ID='10_MIN'
            
            if Group_ID in ["CONTROLTEST_DMSO", "FORSKOLIN"] and Experiment_Name=="FORSKOLIN":
                groups[Group_ID] = groups.get(Group_ID, set()) | set([Animal_ID])
                if Animal_ID not in animals:
                    animals[Animal_ID] = {}
                animals[Animal_ID][Subgroup_1_ID] = fname
    return groups, animals

def parse_spines_csv_header(fname):
    res = []
    with open(fname, 'r') as f:
        for i in xrange(HEADER_LINES):
            res.append(f.readline().strip().split(",")[1])
    return tuple(res)

########################################################################################

def for_each_spine_pair_from_excel_group(excel, inp_catalogue, group_id, 
                                sub_from_id, sub_to_id):
    '''
    Yields matched pairs of spines from passed group and given sub_groups.
    '''
    groups, animals = parse_excel_on_spines(excel)
    for spine_id, features_prev, features in for_each_spine_pair_from_group(animals,
                                                                groups, 
                                                                inp_catalogue, 
                                                                group_id,
                                                                sub_from_id, 
                                                                sub_to_id):
        yield spine_id, features_prev, features
            
def for_each_spine_pair_from_group(animals, groups, inp_catalogue, 
                                group_id, sub_from_id, sub_to_id):
    '''
    Yields matched pairs of spines from passed group and given sub_groups.
    Uses already parsed dictionaries: animals and groups.
    '''
    for animal_id in groups[group_id]:
        #gather differences from animals:
        for spine_id, features_prev, features in \
        for_each_spine_pair(inp_catalogue+animals[animal_id][sub_from_id],
                        inp_catalogue+animals[animal_id][sub_to_id]):
            yield spine_id, features_prev, features
    

def for_each_spine(fname, start_line = 18, end_line = -2):
    '''
    @param fname1: file with information about consecutive spines. Each 
     spine is described as id (unique number in fname1) and list of real
     valued features.
    @type fname1: string
    
    file has records, where first element is id, the rest are real valued
    features.
    '''

    #create a dictionary of spine numbers to feature values
    with open(fname) as f:
        for line in f.readlines()[start_line:end_line]:
            line = line.replace(",", ";")
            features = map( lambda x: x.strip(), line.split(';') )
            yield features


def for_each_spine_pair(fname1, fname2, start_line = 18, end_line = -2):
    '''
    @param fname1: file with information about consecutive spines. Each 
     spine is described as id (unique number in fname1) and list of real
     valued features.
    @type fname1: string
    @param fname2: file with information about consecutive spines. Each 
     spine is described as id (unique number in fname1) and list of real
     valued features. Each id occurs exactly once in fname1 and fname2.
    @type fname2: string
    
    
    Yields matched pairs of spines from fname1 and fname2 (each spine occurs 
    once in fname1 and fname2). Matching is by id.
    Each file has records, where first element is id, the rest are real valued
    features.
    '''

    #create a dictionary of spine numbers to feature values
    id2feature_vals = {}
    with open(fname1) as f1:
        for line in f1.readlines()[start_line:end_line]:
            features = map( lambda x: x.strip(), line.split(',') )
            id2feature_vals[ features[0] ] = features
    
    #going through the second file calculate the diffeneces for each feature
    with open(fname2) as f2:
        for line in f2.readlines()[start_line:end_line]:
            features = map( lambda x: x.strip(), line.split(',') )
            spine_id = features[0]
            if spine_id in id2feature_vals:#maybe the id is not there after all?
                features_prev = id2feature_vals[ spine_id ]
                #condition of parsability:
                if get_differences(features_prev[1:], features[1:], False):
                    yield spine_id, features_prev[1:], features[1:]
            
def for_each_spine_triple(fname1, fname2, fname3, start_line = 18, end_line = -2):
    '''
    @param fname1: file with information about consecutive spines. Each 
     spine is described as id (unique number in fname1) and list of real
     valued features.
    @type fname1: string
    @param fname2: file with information about consecutive spines. Each 
     spine is described as id (unique number in fname1) and list of real
     valued features. Each id occurs exactly once in fname1 and fname2.
    @type fname2: string
    @param fname3: file with information about consecutive spines. Each 
     spine is described as id (unique number in fname1) and list of real
     valued features. Each id occurs exactly once in fname1 and fname3.
    @type fname3: string
    
    
    Yields matched triples of spines from fname1, fname2 and fname3 
    (each spine occurs once in fnamex, x=1, 2, 3). Matching is by id.
    Each file has records, where first element is id, the rest are real valued
    features.
    '''
    print "[utils.for_each_spine_triple] fname1, fname2, fname3:", fname1, fname2, fname3
    #create a dictionary of spine numbers to feature values
    id2feature_vals = {}
    with open(fname1) as f1:
        for line in f1.readlines()[start_line:end_line]:
            features = map( lambda x: x.strip(), line.split(',') )
            id2feature_vals[ features[0] ] = features
    for spine_id, features2, features3 in for_each_spine_pair(fname2, fname3):
    	try:
            yield spine_id, id2feature_vals[spine_id][1:], features2, features3
       	except:
       		print "[utils.for_each_spine_triple] spine_id:", spine_id, type(spine_id), "not found in timestamp first - skipping"
       	#	#raise
########################################################################################

def get_differences(features_prev, features_after, relative):
    '''
    Returns difference between pair of feature vectors; If it is not possible
    to return one, returns empty vector.
    '''
    differences = []
    ok = True
    #spine_id = features_prev[0]
    for i in xrange(len(features_prev)):
        #check if values are even parsable: some are missing!
        try:
            d = float(features_after[i]) - float(features_prev[i])
            if relative:
                d /= float(features_prev[i])
            differences.append(d)
        except:
            ok = False
            break
    if ok:
        return differences
    return []

from itertools import izip
def calc_col2changes(col2vals, t0features, t1features, relative=True):
    """Applies get_differences(t0list, t1list, relative) for features from two lists t0features, t1features taking data from col2vals dictionary."""
    col2changes = {}
    for t0feature, t1feature in izip(t0features, t1features):
        t0list = col2vals[t0feature]
        t1list = col2vals[t1feature]        
        col2changes[t1feature] = get_differences(t0list, t1list, relative)
    return col2changes


def for_each_spine_difference(fname1, fname2, start_line = 18, end_line = -2, 
    relative = True):
    ''' 
    Yields id and list of diffences of feature values for matched pairs 
    of spines from fname1 and fname2 (each spine occurs once in fname1 
    and fname2). Matching is by id.
    
    @param fname1: file with information about consecutive spines. 
     Each spine is described as id (unique number in fname1) and list 
     of real valued features.
    @type fname1: string
    @param fname2: file with information about consecutive spines. 
     Each spine is described as id (unique number in fname1) and 
     list of real valued features. Each id occurs exactly once in 
     fname1 and fname2.
    @type fname2: string
    '''
    for spine_id, features_prev, features_after in for_each_spine_pair(fname1, 
                                                                    fname2, 
                                                                    start_line, 
                                                                    end_line):
        differences = get_differences(features_prev, features_after, relative)
        if len(differences) > 0:
            yield spine_id, differences

def gather_feature_lists(f):
    '''
    For file f, gather all occurences of values in columns.
    Return dictionary wih keys: feature id and values: list of values taken
    by features (with repetitions if needed).
    '''
    feature_lists = {}
    for l in f:
        for i, feature in enumerate(l.split()):
            feature_lists[i] = feature_lists.get(i, []) + [feature]
    return feature_lists

def read_feature_lists(fname):
    '''
    Return list of features of spines from file: fname.
    feature_lists - first dimension denotes a feature, second dimension denotes a spine.
    '''
    with open(fname) as f:
        header = f.readline().strip().split()#pass header
        feature_lists = gather_feature_lists(f)
    return header, feature_lists

#############################################################################################################

def load_csv(f, csvseparator=' ', cast_method=str):
    """Loads CSV file and returns dictionary {column-name: list-of-values in this column}."""
    import csv
    dmsoreader = csv.reader(f, delimiter=csvseparator)            
    
    header = dmsoreader.next()
    
    col2vals = {}
    for row in dmsoreader: 
        for col,val in zip(header,row):
            col2vals[col] = col2vals.get(col,[])+[cast_method(val)]

    return col2vals

def list_remove_indexes(lst, indexes):
    """Returns list with specified indexes removed."""
    indexes = set(indexes)
    return list(v for ix,v in enumerate(lst) if ix not in indexes)


def filterout_columns_col2vals(col2vals, column_names, illegal_values = set([0, 0.0, None]) ):
    """Removes element from all lists of values if element has illegal value in any column (columns from column_names list are considered).

    col2vals dictionary {column-name: list-of-values in this column} (some representation of a table)
    column_names list of column names to considered
    """
    all_col_names = col2vals.keys()
    for col in column_names:
        vals        = col2vals[col] #choose values in this column
        bad_indexes = list(ix for ix,val in enumerate(vals) if val in illegal_values) #find incorrect elements
        #filter out row from all columns:
        for c in all_col_names:
            col2vals[c] = list_remove_indexes(col2vals[c], bad_indexes)
    return col2vals


import sys    
def print_dict_of_lists(d, f=sys.stdout):
    """Prints dictionary that have lists as values."""
    #f.write("<dict>\n")
    for k in sorted(d):
        lst = d[k]
        f.write(str(k)+"[size:"+str(len(lst))+"]:\t")
        f.write(str(lst[:100])[:100]+"...\n")
    #f.write("</dict>\n")

import string
def feature_shortname(feature_name):
    """Returns short version of a feature name."""
    return reduce(lambda l1,l2: l1+l2, (part[0] for part in feature_name.split("_") if part[0] in string.lowercase) ) # or part[0] in string.digits

def features_shortnames(features_names):
    """Returns short version of a features names from list features_names."""
    return list(feature_shortname(feature_name) for feature_name in  features_names)

def save_spines_by_indices(fname, header, indices, feature_lists):
    '''
    Stores spines denoted by indices to fname. 
    At the beginning, header is put to fname.
    '''
    sys.stdout = open(fname, 'w')
    print header
    for spine1 in indices:
        print " ".join([str(feature_lists[x][spine1]) for x in xrange(len(feature_lists))])

#############################################################################################################
import os
def ensure_dir(f):
    '''
    Ensures that dir f exists, if not then creates it
    '''
    d = os.path.dirname(f)
    if not os.path.exists(d):
        os.makedirs(d)

#############################################################################################################

SPINE_WTKO_IDS = nencki_feature_names+['mean_brightness','mean_brightness_GREEN','mean_brightness_BLUE','membrane_brightness_GREEN','membrane_brightness_BLUE','BCKG_sub_brght_GREEN','BCKG_sub_brght_BLUE','in_spine_pearson']

from os import walk
def list_files(mypath):
    '''
    Lists files from given mypath (no catalogues, no recursion).
    '''
    #print "len(SPINE_WTKO_IDS):", len(SPINE_WTKO_IDS)
    f = []
    for (dirpath, dirnames, filenames) in walk(mypath):
        f.extend(filenames)
        break
    return map(lambda x: mypath+x, f)

def collect_spines_wtko(input, output):
    '''
    Gathers data from multiple files in a catalogue (input) 
    with only one timestamp describing them (plain features).
    
    Writes them to a single csv file. 
    
    input - catalogue with files .csv
    output - name of output file
    '''
    f = list_files(input)
    f = filter(lambda x: x.endswith(".csv"), f)
    #print "[collect_spines_wtko] f:", f
    
    spines = []
    for fname in f:
        for spine in for_each_spine(fname, start_line = 19, end_line = -3):
            #print "spine:", spine
            if len(spine) != len(SPINE_WTKO_IDS):
                print "ERROR!!"
            spine = map(lambda x: float(x), spine)
            spines.append([fname.split("/")[-1].replace(" ", "_")] + spine)
    #print spines
    with open(output, 'w') as fwrite:
        #put header at the beginning
        feature_header = SPINE_WTKO_IDS
        fwrite.write(" ".join(["unique_id", "source_id"]+feature_header)+"\n")
            
        for identification, spine in enumerate(spines):
            fwrite.write(" ".join(map(str, [identification]+spine))+"\n")

