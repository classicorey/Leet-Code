# Given an array of integers nums and an integer target, return indices of the two numbers such that they add up to target.
## You may assume that each input would have exactly one solution, and you may not use the same element twice.
## You can return the answer in any order.

class Solution(object):
    #Start a method that accepts an array of ints as "nums", and the target number to add up to as "target"
    def twoSum(self, nums, target):
        #Initialize the index counters for each number to add
        firstIndex = 0
        secondIndex = 1

        #Start a for loop to iterate through the entire nums array with two numbers looking for target to add
        for i in range(len(nums)):
            #If the numbers at the first and second indexes in the array add up to the target,
            if nums[firstIndex] + nums[secondIndex] == target:
                #Return both indicies
                return firstIndex, secondIndex
            #If they do not add up to the target,
            else:
                #Increment each array index
                firstIndex += 1
                secondIndex += 1