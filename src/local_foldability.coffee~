FOLD = require('fold')

lf = exports

lf.single_vertex = (v, fold) ->
	#Takes the index of a single vertex as input, checks the adjacent edges and things, and 
	#returns the foldability of that vertex
	
	vertex_coords = fold.vertices_coords
	adjvertices = FOLD.convert.sort_vertices_vertices(fold)[v] 
	len = adjvertices.length
	console.log(len)
	anglesum = 0
	for i in [0..len-1]
		j = (i+1)%len
		console.log(j)
		angle = FOLD.geom.interiorAngle(vertex_coords[adjvertices[j]],vertex_coords[v],vertex_coords[adjvertices[i]])
		console.log(angle)
		if i%2 is 0
			anglesum += angle
		else
			anglesum -= angle

	console.log(anglesum)
	if anglesum is 0
		return true
	return false
		 
		
	
