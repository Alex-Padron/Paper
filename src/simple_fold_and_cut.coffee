geom = require "./geom.coffee"

simple_fold_and_cut = exports

simple_fold_and_cut.find_symmetry = (fold) ->
  vertices_map = {}
  for edge in fold.graph_edges
    for v1 in edge
      for v2 in edge
        v1 = v1.toString()
        v2 = v2.toString()
        if v1 is v2
          continue
        if not vertices_map[v1]
          vertices_map[v1] = []
        vertices_map[v1].push v2

  symmetric_edges = []
  for edge in fold.graph_edges
    left = edge[0]
    right = edge[1]
    if simple_fold_and_cut.find_symmetric_vertices(fold, left, right, edge, vertices_map)
      symmetric_edges.push edge
  return symmetric_edges

simple_fold_and_cut.find_symmetric_vertices = (fold,
  left,
  right,
  edge,
  vertices_map,
  checked_left = []
  checked_right = []
) ->
  if left in checked_left and right in checked_right
    return true
  checked_left.push left
  checked_right.push right
  found_matches = []
  tracked_edges = []
  paired_edges = []
  for next_left in vertices_map[left]
    for next_right in vertices_map[right]
      tracked_edges.push [left, next_left]
      tracked_edges.push [right, next_right]
      point_symmetric = geom.perpendicular_bisector_symmetric(fold.graph_vertices[next_left],
        fold.graph_vertices[next_right], fold.graph_vertices[edge[0]],
        fold.graph_vertices[edge[1]])
      if point_symmetric
        if simple_fold_and_cut.find_symmetric_vertices(fold,
          next_left, next_right, edge, vertices_map, checked_left, checked_right)
          found_matches.push next_left
          found_matches.push next_right
          paired_edges.push [left, next_left]
          paired_edges.push [right, next_right]

  for vertex in vertices_map[left]
    if vertex not in found_matches
      return false
  for vertex in vertices_map[right]
    if vertex not in found_matches
      return false
  for edge in tracked_edges
    found_solution = false
    for pair in paired_edges
      if pair[0] == edge[0] and pair[1] == edge[1]
        found_solution = true
    if not found_solution
      return false
  return true
