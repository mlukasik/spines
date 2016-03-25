PREFIX = "/home/michal/workspace/spines_bitbucket/data/140719_olddata+coordinates/"
csv1 = PREFIX+"FORSKOLIN_triple.txt"
csv2 = PREFIX+"CONTROLTEST_DMSO_triple.txt"

spine_cnt = 100

res_catalogue = PREFIX+"filtered_"+str(spine_cnt)+"/"

import os
d = os.path.dirname(res_catalogue)
if not os.path.exists(d):
    os.makedirs(d)

from utils import ensure_dir
ensure_dir(res_catalogue)


#uncomment, if you want to have additional stopping criterion apart from
#maximum number of pair drawn
def stop_criterion(distances, spine1, spine2):
	if distances[spine1][spine2] < 2222:
		return False
	return True


outfile_spines1 = res_catalogue+"FORSKOLIN_triple.txt"
outfile_spines2 = res_catalogue+"CONTROLTEST_DMSO_triple.txt"
