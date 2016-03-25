from utils import collect_spines_wtko
import sys

try:
    input = sys.argv[1]
except:
    print "Argument #1: catalogue with input .csv files"
    sys.exit(1)
try:
    output = sys.argv[2]
except:
    print "Argument #2: output file path."
collect_spines_wtko(input, output)