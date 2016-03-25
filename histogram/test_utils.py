from utils import get_perc_diff, maximum_contigous_region_of_dominance
import unittest

class testGetPercDiff(unittest.TestCase):

    def test_get_perc_diff1(self):
        l1 = [1, 3]
        l2 = [5, 3]
        val = get_perc_diff(l1, l2, xrange(max(l1+l2)))
        self.assertEqual(val, 0.5)

    def test_get_perc_diff2(self):
        l1 = [1]
        l2 = [5]
        val = get_perc_diff(l1, l2, xrange(max(l1+l2)))
        self.assertEqual(val, 1)
    
    def test_get_perc_diff3(self):
        l1 = [1]
        l2 = [1]
        val = get_perc_diff(l1, l2, xrange(max(l1+l2)))
        self.assertEqual(val, 0)
        
    def test_get_perc_diff4(self):
        l1 = [1, 2, 5]
        l2 = [1, 3, 5]
        val = get_perc_diff(l1, l2, [0, 6])
        self.assertEqual(val, 0)
    
class TestMaximumContigousRegionOfDominance(unittest.TestCase):

    def test_case1(self):
        l1 = [1, 3, 4, 2, 6, 7, 8]
        l2 = [5, 3, 1, 2, 1, 2, 1]
        (perc_left, ind_left, perc_right, ind_right) = \
        maximum_contigous_region_of_dominance(l1, l2)
        self.assertEqual(ind_left, 2)
        self.assertEqual(perc_right, 0)

if __name__ == "__main__":
    unittest.main()
