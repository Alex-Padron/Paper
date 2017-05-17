geom = require './geom.coffee'
sfac = require './simple_fold_and_cut.coffee'

print = (str) -> console.log str

failed = false
assert = (b, msg) ->
  if not b
    print "FAIL " + (if msg then msg else "")
    failed = true

arr_eq = (a1, a2) ->
  if a1.length != a2.length
    return false
  if a1 instanceof Array
    if a2 instanceof Array
      for v1, i in a1
        v2 = a2[i]
        if not arr_eq(v1, v2)
          return false
      return true
    else
      return false
  else
    return a1 == a2

assert(arr_eq([], []))
assert(arr_eq([1,2,3], [1,2,3]))
assert(not arr_eq([1,2,3], [1,3,2]))
assert(not arr_eq([1,2,3], [1,2,[3]]))
assert(arr_eq([[1], 2, [[3]]],[[1], 2, [[3]]]))
print "Testing simple fold and cut..."

vertices_map = {}
vertices_map[1] = [0]
vertices_map[0] = [1]
v1 = [-1, 0, 0]
v2 = [1, 0, 0]
e1 = [0, 1]
fold = {}
fold.graph_vertices = [v1, v2]
fold.graph_edges = [e1]
assert(sfac.find_symmetric_vertices(fold, 0, 1, e1, vertices_map))

v3 = [1, 1, 0]
e2 = [1, 2]
fold.graph_vertices = [v1, v2, v3]
fold.graph_edges = [e1, e2]
vertices_map[1] = [0, 2]
vertices_map[2] = [1]
assert(not sfac.find_symmetric_vertices(fold, 0, 1, e1, vertices_map))

v4 = [-1, 1, 0]
e3 = [1, 2]
fold.graph_vertices = [v1, v2, v3, v4]
fold.graph_edges = [e1, e2, e3]
vertices_map[1] = [0, 2]
vertices_map[2] = [1]
vertices_map[0] = [1, 3]
vertices_map[3] = [0]
assert(sfac.find_symmetric_vertices(fold, 0, 1, e1, vertices_map))

e4 = [3, 2]
fold.graph_edges.push e4
vertices_map[3].push 2
vertices_map[2].push 3
assert(sfac.find_symmetric_vertices(fold, 0, 1, e1, vertices_map))

e5 = [3, 1]
fold.graph_edges.push e5
vertices_map[3].push 1
vertices_map[1].push 3
assert(not sfac.find_symmetric_vertices(fold, 0, 1, e1, vertices_map))

# two connected points, should have symmetry between them
v1 = [-1, 0, 0]
v2 = [1, 0, 0]
e1 = [0, 1]
fold = {}
fold.graph_vertices = [v1, v2]
fold.graph_edges = [e1]
assert(arr_eq(sfac.find_symmetry(fold), [[0, 1]]))

# a square missing a side, the middle edge only has symmetry
v3 = [1, 1, 0]
v4 = [-1, 1, 0]
fold.graph_vertices.push v3
fold.graph_vertices.push v4
e2 = [1, 2]
e3 = [0, 3]
fold.graph_edges.push e2
fold.graph_edges.push e3
assert(arr_eq(sfac.find_symmetry(fold), [[0, 1]]))

# a square, every edge should have symmetry
e4 = [2, 3]
fold.graph_edges.push e4
assert(arr_eq(sfac.find_symmetry(fold),
 [ [ 0, 1 ], [ 1, 2 ], [ 0, 3 ], [ 2, 3 ] ]))

if not failed
  print "...passed"
