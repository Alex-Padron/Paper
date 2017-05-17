geom = require './geom'
simple_fold = exports

# Performs a simple fold without checking for collisions
# @param fold {FOLD object} to perform fold on
# @param edges {int tuple} edge to fold on
# @param angle {int radians} to fold
# @return whether the fold was successful.
simple_fold.fold = (fold, edge, angle) ->
  partition = simple_fold.partition(fold, edge)
  if not partition
    return false
  left = partition.left
  axis = geom.sub(fold.vertices_coords[edge[0]], fold.vertices_coords[edge[1]])
  rotated = {}
  # keep right fixed and move left
  for e in left
    for vertex in e
      if vertex == edge[0] or vertex == edge[1]
        continue
      if rotated[vertex]
        continue
      rotated[vertex] = true
      new_vertex = geom.rotate(fold.vertices_coords[vertex], axis, angle)
      fold.vertices_coords[vertex] = new_vertex
  return true

# creates two sets of edges that are disjoint around the edge
# @param fold {FOLD object} to perform partition on
# @param edge {int tuple} that is partitioning fold
# @return {left: {int tuple}[], right: {int tuple}[]} sets of
# edges divided by edge. edge will be included in both left and
# right
simple_fold.partition = (fold, edge) ->
  neighbors = simple_fold.find_neighboring_faces(fold, edge)
  # for simple folds the edge should have two adjacent faces
  if neighbors.length != 2
    return null
  left_edges = simple_fold.edges_from_face(fold, neighbors[0]).filter (e) -> e != edge
  right_edges = simple_fold.edges_from_face(fold, neighbors[1]).filter (e) -> e != edge
  left = simple_fold.search_neighbors_rec(fold, left_edges, [neighbors[1]])
  right = simple_fold.search_neighbors_rec(fold, right_edges, [neighbors[0]])
  return {'left': left, 'right': right}

# Check whether a fold contains an edge, order sensitive
# @param fold {FOLD object} to check in
# @param edge {int tuple} to query
# @return whether edge is in fold.edges_vertices
simple_fold.contains_edge = (fold, edge) ->
  for e in fold.edges_vertices
    if e[0] == edge[0] and e[1] == edge[1]
      return true
  return false

# Get all the faces surrounding an edge. Will only return
# faces that already are in the fold, handling ordering issues
# @param fold {FOLD object} to query on
# @param face {int[]} list of vertices contained in the face
# @return {int[][]} set of edges around face
simple_fold.edges_from_face = (fold, face) ->
  edges = []
  for _, i in face
    start = face[i]
    end = face[(i + 1) % face.length]
    for edge in [[start, end],[end, start]]
      if simple_fold.contains_edge(fold, edge)
        edges.push edge
  return edges

# Get the faces around an edge
# @param fold {FOLD object} to query on
# @param edge {int tuple} the edge to get faces around
# @return {int[][]} list of faces around edge
simple_fold.find_neighboring_faces = (fold, edge) ->
  found_faces = []
  start = edge[0]
  end = edge[1]
  for face in fold.faces_vertices
    for _, i in face
      if (face[i] == start and face[(i+1) % face.length] == end)
        found_faces.push(face)
      if (face[i] == end and face[(i+1) % face.length] == start)
        found_faces.push(face)
  return found_faces

# Perform a BFS to find all the edges that can be reached starting
# from edges.
# @param fold {FOLD object} to query on
# @param edges {int[][]} list of edges that are the seed of the search
# @param found_faces {int[][]} set of faces that are marked already
# explored and cannot be explored again
# @return {int[][]} a list of the edges found by the search
simple_fold.search_neighbors_rec = (fold, edges, found_faces) ->
  found_edges = []
  checked = {}
  while edges.length > 0
    to_explore = edges.pop()
    if checked[to_explore]
      continue
    checked[to_explore] = true
    found_edges.push to_explore
    adj_faces = simple_fold.find_neighboring_faces(fold, to_explore)
    for face in adj_faces
      if face in found_faces
        continue
      found_faces.push(face)
      for edge in simple_fold.edges_from_face(fold, face)
        if not checked[edge]
          edges.push(edge)
  return found_edges
