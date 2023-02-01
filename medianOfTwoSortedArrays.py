#Given two sorted arrays nums1 and nums2 of size m and n respectively, return the median of the two sorted arrays.
##The overall run time complexity should be O(log (m+n)).
class Solution(object):
    def findMedianSortedArrays(self, nums1, nums2):
        """
        :type nums1: List[int]
        :type nums2: List[int]
        :rtype: float
        """
        #Merge the two input lists,
        mergedNums = nums1 + nums2
        #Sort the merged list.
        mergedNums.sort()
        #If there are not even number of elements in the list,
        if len(mergedNums) % 2 != 0:
            #Return the middle element in the merged list.
            return mergedNums[int(len(mergedNums)/2)]
        #If there are an even number of elements in the list,
        else:
            #Instantiate the first index to add.
            medOneIndex = mergedNums[len(mergedNums)/2] - 2
            #Instantiate the second index to add.
            medTwoIndex = medOneIndex + 1
            #Add the values at the two above indexes, and halve the result
            median = float((mergedNums[medOneIndex] + mergedNums[medTwoIndex])) / 2
            #Return the calculated median.
            return median