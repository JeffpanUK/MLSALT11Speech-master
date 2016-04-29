def levenshtein(entry1,entry2):
	if len(entry1) > len(entry2):
		entry1,entry2 = entry2,entry1
	if len(entry1) == 0:
		return len(entry2)
	if len(entry2) == 0:
		return len(entry1)
	entry1_length = len(entry1) + 1
	entry2_length = len(entry2) + 1
	distance_matrix = [range(entry2_length) for x in range(entry1_length)] 
	#print distance_matrix
	for i in range(1,entry1_length):
		for j in range(1,entry2_length):
			deletion = distance_matrix[i-1][j] + 1
			insertion = distance_matrix[i][j-1] + 1
			substitution = distance_matrix[i-1][j-1]
			if entry1[i-1] != entry2[j-1]:
				substitution += 1
			distance_matrix[i][j] = min(insertion,deletion,substitution)
	# print distance_matrix
	return distance_matrix[entry1_length-1][entry2_length-1]

if __name__ == '__main__':
	a=levenshtein('happy','heal')
	print a