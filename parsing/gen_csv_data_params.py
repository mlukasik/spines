#PREFIX = "../../../Dropbox/ICM/Michal/Nencki/"
#PREFIX = "../DATA/Nencki_spine_data_updated_with_extended_control_80713/"
#PREFIX = "../DATA/NON-PARSED/130709_Nencki_spine_data_updated_with_extended_control_removed_feat/"
PREFIX = "../DATA/NON-PARSED/140720_korelacja-spiny/"
excel = PREFIX+"info_new.xlsx"
inp_catalogue = PREFIX
res_path = ""
group_id0 = "0MIN"
group_id1 = "10_MIN"
group_id2 = "40_MIN"
DATA_VERSION = "00"

exlude_not_divisible = 0

#import os
#d = os.path.dirname(res_catalogue)
#if not os.path.exists(d):
#    os.makedirs(d)
group2letter = {"CONTROLTEST_DMSO": "d",
                "FORSKOLIN": "f",
                'CONTROL': 'c',  
                'CONTROL_D': 'cd', 
                'GM6001': 'g'}
separate_files = True

load_groups_animals_info_from_excel = False