# Given an input string s and a pattern p, implement regular expression matching with support for '.' and '*' where:
#- '.' Matches any single character.​​​​
#- '*' Matches zero or more of the preceding element.
## The matching should cover the entire input string (not partial).
class Solution(object):
    def isMatch(self, s, p):
        """
        :type s: str
        :type p: str
        :rtype: bool
        """
        #If there is a * in the p string,
        if "*" in p:
            #Return true, since it will always have 0 or more characters.
            #Not entirely clear on this rule. I would love to ask clarifying questions
            return True
        #If there is a . in the p string,
        if "." in p:
            #If the other element in the p string is found anywhere in s,
            if p[1] in s:
                #Return true.
                return True
        #If the p string and the s string are the same,
        if p == s:
            #Return true.
            return True
        #If none of the conditions match, return false.
        return False