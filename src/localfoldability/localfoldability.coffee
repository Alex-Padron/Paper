convert = require('../convert.coffee')
geom = require('../geom.coffee')
ds = require("../data_structures.coffee")

lf = exports


lf.kawasaki_single_vertex = (v, fold) ->
	#Takes the index of a single vertex as input, checks the adjacent edges and things, and 
	#returns the Kawasaki foldability of that vertex
	
	vertex_coords = fold.vertices_coords
	adjvertices = convert.sort_vertices_vertices(fold)[v] 
	len = adjvertices.length
	#console.log(len)
	anglesum = 0
	for i in [0..len-1]
		j = (i+1)%%len
		#console.log(j)
		angle = geom.interiorAngle(vertex_coords[adjvertices[j]],vertex_coords[v],vertex_coords[adjvertices[i]])
		#console.log(angle)
		if i%%2 is 0
			anglesum += angle
		else
			anglesum -= angle

	#console.log(anglesum)
	if anglesum is 0
		console.log("Vertex ", v, " satisfies the Kawasaki criterion")
		return true
	console.log("Vertex ", v, " does NOT satisfy the Kawasaki criterion")
	return false
		 
		
	
lf.kawasaki_all_vertex = (fold) ->
	#Checks Kawasaki condition on every vertex of a crease pattern

	vertex_coords = fold.vertices_coords
	vertex_num = vertex_coords.length
	flag = true
	for i in [0..vertex_num-1]
		if lf.kawasaki_single_vertex(i, fold) is false
			flag = false
	if flag is true
		console.log("Every vertex in this crease pattern satisfies the Kawasaki criterion")
		return true
	else
		console.log("Not every vertex in this crease pattern satisfies the Kawasaki criterion")
		return false
	
		
lf.maekawa_single_vertex = (v, fold) ->
	#Given an MV assignment, checks Maekawa condition on this vertex
	
	edges_assignment = fold.edges_assignment
	mountain_count = 0
	valley_count = 0
	for e,i in fold.edges_vertices
		[u,w] = e
		#console.log(u, w)
		if u == v || w == v
			#console.log("Found the vertex!")
			#console.log(edges_assignment[i])
			if edges_assignment[i] is "B"
				#console.log("Vertex ", v, " satisfies the Maekawa condition")
				return true
			if edges_assignment[i] is "M"
				mountain_count += 1
			if edges_assignment[i] is "V"
				valley_count += 1
		
	if mountain_count-valley_count == 2 || valley_count-mountain_count == 2
		console.log("Vertex ", v, " satisfies the Maekawa condition")
		return true
	console.log("Vertex ", v, " does not satisfy the Maekawa condition")
	false

lf.maekawa_all_vertex = (fold) ->
	#Given an MV assignment, checks Maekawa condition on every vertex

	vertex_coords = fold.vertices_coords
	vertex_num = vertex_coords.length
	flag = true
	for i in [0..vertex_num-1]
		if lf.maekawa_single_vertex(i, fold) is false
			flag = false
	if flag is true
		console.log("Every vertex in this mountain-valley assignment satisfies the Maekawa condition")
		return true
	else
		console.log("Not every vertex in this crease pattern satisfies the Maekawa condition")
		return false


class lf.svAngle
	constructor: (x,v,w) ->
		#Has two edges, in order counterclockwise
		@angle = x
		@edge_0 = v
		@edge_1 = w

lf.crimpable_single_vertex = (v, fold) ->
	#Given an MV assignment and a single vertex, checks to see if it's flat foldable 
	#Start by initializing a list of nonstrict locally minimum angles. Then, at each step
	#crimp the first one (removing it from the min-list) and remove it

	vertex_coords = fold.vertices_coords
	adjvertices = convert.sort_vertices_vertices(fold)[v]
	len = adjvertices.length

	#Minima points to the element of angles that is removed
	minima = new ds.Deque

	#Angles actually just has angles
	angles = new ds.Deque

	edges_assignment = fold.edges_assignment
	assignment_dict = {}
	sv_assignment_dict = {}
	for i in [0..edges_assignment.length-1]
		assignment_dict[fold.edges_vertices[i]] = edges_assignment[i]
		assignment_dict[fold.edges_vertices[i].reverse()] = edges_assignment[i]
	for i in [0..len-1]
		sv_assignment_dict[[v,i]] = assignment_dict[[v,adjvertices[i]]]

	#Now you have a dictionary keyed by [v,w] that tells you assignment, where w is in the range 0 to len(adjvertices)-1 

	for j in [0..len-1]
		m = (j+2)%%len
		k = (j+1)%%len
		i = (j-1)%%len
		prev_angle = new lf.svAngle(geom.interiorAngle(vertex_coords[adjvertices[j]],vertex_coords[v],vertex_coords[adjvertices[i]]),[v,i],[v,j])
		curr_angle = new lf.svAngle(geom.interiorAngle(vertex_coords[adjvertices[k]],vertex_coords[v],vertex_coords[adjvertices[j]]),[v,j],[v,k])
		next_angle = new lf.svAngle(geom.interiorAngle(vertex_coords[adjvertices[m]],vertex_coords[v],vertex_coords[adjvertices[k]]),[v,k],[v,m])

		angles.head_push(curr_angle)

		if curr_angle.angle <= next_angle.angle and curr_angle.angle <= prev_angle.angle and sv_assignment_dict[[v,j]] != sv_assignment_dict[[v,k]]
			minima.head_push(angles.head)

	#Connect the head and tail of angles
	angles.tail.prev = angles.head
	angles.head.next = angles.tail
	
	#Now for crimping!
	while minima.length > 0
		#While the list is not empty, keep crimping!
		#Crimping means folding the local minimum under one of the two adjacent angles. Suppose originally \theta_1, \theta_2, \theta_3
		#The end result is \theta_1+\theta_3-\theta_2
	
		#Get the first local minimum - this points to an angle to be removed
		#Replace pred--el--succ with --(succ+pred-el)--
		el = minima.head_pop()
		succ = el.next
		pred = el.prev

		el.value.angle = succ.value.angle+pred.value.angle-el.value.angle
		el.value.edge_0 = pred.value.edge_0
		el.value.edge_1 = succ.value.edge_1
		pred.prev.next = el
		succ.next.prev = el
		el.next = succ.next
		el.prev = pred.prev
		
		succ = el.next
		pred = el.prev

		#Check if the newly created angle is itself a local minima, and if the two edges are opposite
		if el.value.angle <= el.next.value.angle and el.value.angle <= el.prev.value.angle and sv_assignment_dict[el.value.edge_0] != sv_assignment_dict[el.value.edge_1]
			minima.head_push(el)
		#Check if the next angle is now a local minimum
		if succ.value.angle <= succ.next.value.angle and succ.value.angle <= succ.prev.value.angle and sv_assignment_dict[succ.value.edge_0] != sv_assignment_dict[succ.value.edge_1]
			minima.head_push(succ)
		#Check if the previous angle is now a local minimum
		if pred.value.angle < pred.next.value.angle and pred.value.angle < pred.prev.value.angle and sv_assignment_dict[pred.value.edge_0] != sv_assignment_dict[pred.value.edge_1]
			minima.head_push(pred)


	console.log "and when all's said and done, the number of angles left is"
	console.log angles.length
	if angles.length == 0
		console.log "Flat foldable!"
	if angles.length == 2
		console.log "Not sure lol"
