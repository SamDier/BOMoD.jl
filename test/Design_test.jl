

first_unorderd_design =construct_design(mt_String_array,3)
first_orderd_design =construct_design(mt_String_array,3,order = true)

# test get space
space_1_unordered = getspace(first_unorderd_design)
space_1_ordered =  getspace(first_orderd_design)


space_1_b_ordered = getspace(first_unorderd_design, full = true)
space_1_unordered = getspace(first_orderd_design, full = true)


second_unorderd_design =construct_design(mt_String_array,3,Compose_Construct_backup)
