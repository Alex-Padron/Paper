simple_fold = require './simple_fold'

print = (str) -> console.log str

failed = false
assert = (b, msg) ->
  if not b
    print "FAIL " + (if msg then msg else "")
    failed = true

arr_cont = (x, y) ->
  for el in y
    valid = true
    if el.length != x.length
      continue
    for _, i in x
      if x[i] != el[i]
        valid = false
    if valid
      return true
  return false

close = (x, y) ->
  return Math.abs(x - y) < 0.001

print "Testing simple fold..."
fold = {}
fold.vertices_coords = [[0,0,0], [1,0,0], [1,1,0], [0,1,0], [-1,1,0], [-1,0,0]]
fold.edges_vertices = [[0,1], [1,2], [2,3], [3,0], [3,4], [4,5], [5,0]]
fold.faces_vertices = [[0,1,2,3], [3,4,5,0]]

edges = simple_fold.edges_from_face(fold, fold.faces_vertices[0])
assert(edges[0][0] == 0)
assert(edges[0][1] == 1)
assert(edges[1][0] == 1)
assert(edges[1][1] == 2)
assert(edges[2][0] == 2)
assert(edges[2][1] == 3)
assert(edges[3][0] == 3)
assert(edges[3][1] == 0)

edges = simple_fold.edges_from_face(fold, fold.faces_vertices[1])
assert(edges[0][0] == 3)
assert(edges[0][1] == 4)
assert(edges[1][0] == 4)
assert(edges[1][1] == 5)
assert(edges[2][0] == 5)
assert(edges[2][1] == 0)
assert(edges[3][0] == 3)
assert(edges[3][1] == 0)

faces = simple_fold.find_neighboring_faces(fold, fold.edges_vertices[0])
assert(faces.length == 1)
face = faces[0]
assert(face[0] == 0)
assert(face[1] == 1)
assert(face[2] == 2)
assert(face[3] == 3)

faces = simple_fold.find_neighboring_faces(fold, fold.edges_vertices[3])
assert(faces.length == 2)
face = faces[0]
assert(face[0] == 0)
assert(face[1] == 1)
assert(face[2] == 2)
assert(face[3] == 3)
face = faces[1]
assert(face[0] == 3)
assert(face[1] == 4)
assert(face[2] == 5)
assert(face[3] == 0)

checked = simple_fold.search_neighbors_rec(fold, [fold.edges_vertices[0]], [])
for edge in fold.edges_vertices
  assert(simple_fold.contains_edge(fold, edge))
assert(Object.keys(checked).length == fold.edges_vertices.length)

checked = simple_fold.search_neighbors_rec(fold, \
  [fold.edges_vertices[3]], \
  [fold.faces_vertices[0]])
assert(Object.keys(checked).length == 4)
for edge in [[3,0], [5,0], [3,4], [4,5]]
  assert(simple_fold.contains_edge(fold, edge))

part = simple_fold.partition(fold, fold.edges_vertices[0])
assert(not part)
part = simple_fold.partition(fold, fold.edges_vertices[3])
left = part.left
right = part.right
assert(left.length == 4)
assert(right.length == 4)
for edge in [[3,0], [0,1], [1,2], [2,3]]
  assert(arr_cont(edge, left))
for edge in [[3,0], [5,0], [3,4], [4,5]]
  assert(arr_cont(edge, right))

fold_copy = JSON.parse(JSON.stringify(fold))
simple_fold.fold(fold_copy, fold_copy.edges_vertices[3], Math.PI/2)
assert(JSON.stringify(fold.faces_vertices) == \
  JSON.stringify(fold_copy.faces_vertices))
assert(JSON.stringify(fold.edges_vertices) == \
  JSON.stringify(fold_copy.edges_vertices))
v = fold_copy.vertices_coords
for i in [0,3,4,5]
  assert(v[i].length == fold.vertices_coords[i].length)
  for _, j in v[i]
    assert(v[i][j] == fold.vertices_coords[i][j])
assert(close(v[1][0], 0))
assert(close(v[1][1], 0))
assert(close(v[1][2], -1))
assert(close(v[2][0], 0))
assert(close(v[2][1], 1))
assert(close(v[2][2], -1))

if not failed
  print "...passed"
