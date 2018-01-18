-- wrapper
local vectors = {
  _VERSION = "Linear Algebra Vectors and Matrices 0.1",
  _DESCRIPTION = "TODO",
  _LICENSE = "MPL2"
}

-- metamethods
local VectorOrMatrix = {}
VectorOrMatrix.__index = VectorOrMatrix

-- namespace of vector code
local vector = {}
vectors.vector = vector
vector.class = function() return VectorOrMatrix end
vector._call = vector.new

-- namespace of matrix code
local matrix = {}
vectors.matrix = matrix
-- has to be same metatable because otherwise
-- the methods for lua to apply multiplication/ect
-- will not work
matrix.class = vector.class
matrix._call = matrix.new

local VECTOR = "vector"
local MATRIX = "matrix"
local COLUMN = "column"
local ROW = "row"

-- List/Singleton value -> Vector
-- Creates a Vector by applying the vector metatable to the input
-- O(n) where n is number of values in list supplied
function vector.new(values)
  values = values or {}
  local inputType = type(values)
  if inputType ~= "table" then
    if inputType == "number" then
      values = { values }
    else
      error("Attempt to create new vector from unsupported type", 2, debug.traceback())
    end
  end
  setmetatable(values, VectorOrMatrix)
  -- provide default _la info but do not
  -- override _la info provided in paramater
  if values._la == nil then
    values._la = {}
  end
  -- signify as vector
  values._la.type = VECTOR
  -- flag for direction of this vector
  -- column signifies a column vector
  -- row signifies a row vector
  values._la.direction = values._la.direction or COLUMN
  -- tracks how many values are in this vector
  values._la.count = values._la.count or table.maxn(values)
  return values
end

-- TODO
function matrix.new(values)
  -- TODO Check values are not malformed
  local result = vector.new(values)
  result._la.type = MATRIX
  -- matrices are implemented as a row vector of
  -- column vectors
  result._la.direction = ROW
  -- _la.count tracks how many column vectors are in this row matrix
  -- and does not need changing
  return result
end

-- TODO Tweak to actually work with StructLists

-- Vector/Matrix, Index -> Value/Vector at index
-- by default acts as foo[bar] access
-- but can be changed to support other representation datatypes
-- such as others in this library
-- all other code assumes this is a constant time operation Θ(1)
-- if the representation datatype was non constant time access then all
-- these runtimes will be wrong
function VectorOrMatrix.access(vectorOrMatrix, i)
  return vectorOrMatrix[i]
end

-- Vector/Matrix, Index, Value -> assigns value to index
-- by default acts as foo[bar] = baz
-- but can be changed to support other representation datatypes
-- such as others in this library
-- all other code assumes this is a constant time operation Θ(1)
-- if the representation datatype was non constant time assignment then all
-- these runtimes will be wrong
function VectorOrMatrix.assign(vectorOrMatrix, i, v)
    vectorOrMatrix[i] = v
end

-- iterator function that uses access defined above instead of
-- direct foo[bar] access, to aid supporting other representation types
-- to that uses access defined above
function VectorOrMatrix._iterator(vectorOrMatrix, i)
  i = i + 1
  local v = vectorOrMatrix:access(i)
  if v then
    return i, v
  end
end

-- Custom ipairs that uses access defined above instead of
-- direct foo[bar] access, to aid supporting other representation types
-- for k, v in ipairs(vector) do
--   ...
-- end
-- will just work even if access and assignment are redefined
function VectorOrMatrix.__ipairs(vectorOrMatrix)
  return VectorOrMatrix._iterator, vectorOrMatrix, 0
end

-- Vector -> True
-- Matrix -> False
-- Θ(1)
function VectorOrMatrix.isVector(vector)
  return vector._la.type == VECTOR
end

-- Vector -> False
-- Matrix -> True
-- Θ(1)
function VectorOrMatrix.isMatrix(matrix)
  return matrix._la.type == MATRIX
end

-- Vector/Matrix -> Vector/Matrix
-- Flips rows for columns
-- Θ(1) for vectors as just flips markers
-- Θ(n) for matrices where n is number of vectors in matrix
function VectorOrMatrix.T(vectorOrMatrix)
  if vectorOrMatrix._la.direction == COLUMN then
    vectorOrMatrix._la.direction = ROW
  else
    vectorOrMatrix._la.direction = COLUMN
  end
  if vectorOrMatrix:isMatrix() then
    local matrix = vectorOrMatrix
    for _, v in ipairs(matrix) do
      -- transpose all vectors in this matrix as well
      v:T()
    end
  end
  return vectorOrMatrix  
end

-- aliases
VectorOrMatrix.t = VectorOrMatrix.T
VectorOrMatrix.transpose = VectorOrMatrix.T
VectorOrMatrix.rotate = VectorOrMatrix.T

-- Vector -> Int (Euclidean length
-- Θ(n) where n is size of vector
function VectorOrMatrix.__len(vector)
  return VectorOrMatrix.pnorm(vector, 2)
end

-- aliases
VectorOrMatrix.length = VectorOrMatrix.__len
VectorOrMatrix.euclidean = VectorOrMatrix.__len

VectorOrMatrix.manhattan = function(v) return VectorOrMatrix.pnorm(v, 1) end

-- Vector, ℕ -> Number (length of vector in this p-norm)
-- 2 is Euclidean distance, and the usual vector length
-- 1 gives Manhattan distance
-- https://en.wikipedia.org/wiki/Lp_space
-- Θ(n) where n is size of vector
function VectorOrMatrix.pnorm(vector, p)
  if not vector:isVector() then
    error("Attempt to calculate lp norm of non vector type", 2, debug.traceback())
  end
  -- ||x||p = (x1^p + x2^p + x3^p .... ) ^ 1/p
  local sum = 0
  for _, v in ipairs(vector) do
    -- |x|^p
    sum = sum + math.abs(v)^p
  end
  return sum^(1/p)
end

-- aliases
VectorOrMatrix.lpnorm = VectorOrMatrix.pnorm
VectorOrMatrix.LpNorm = VectorOrMatrix.pnorm
VectorOrMatrix.lpNorm = VectorOrMatrix.pnorm
VectorOrMatrix.lPNorm = VectorOrMatrix.pnorm
VectorOrMatrix.p = VectorOrMatrix.pnorm

-- Vector/Matrix -> Number of rows in vector/matrix
-- Θ(1)
function VectorOrMatrix.rows(matrix)
  if matrix:isMatrix() then
    if matrix._la.direction == ROW then
      return matrix._la.count
    else
      -- this matrix has been rotated and is now
      -- a column matrix of row vectors
      if matrix:get(1, 1) then
        return matrix:access(1)._la.count
      else
        return 0
      end
    end
  end
  local vector = matrix
  if vector._la.direction == COLUMN then
    if vector:get(1, 1) then
      return 1
    else
      return 0
    end
  else
    return vector._la.count
  end
end

-- Vector/Matrix -> ℕ (number of columns in vector/matrix)
-- Θ(1)
function VectorOrMatrix.columns(matrix)
  if matrix:isMatrix() then
    if matrix._la.direction == COLUMN then
      return matrix._la.count
    else
      -- this matrix is a row matrix of column vectors
      if matrix:get(1, 1) then
        return matrix:access(1)._la.count
      else
        return 0
      end
    end
  end
  local vector = matrix
  if vector._la.direction == COLUMN then
    return vector._la.count
  else
    if vector:get(1, 1) then
      return 1
    else
      return 0
    end
  end
end

-- Vector/Matrix -> ℕ, ℕ (number of rows and columns in vector/matrix respectively)
-- Θ(1)
function VectorOrMatrix.size(matrix)
  return matrix:rows(), matrix:columns()
end

-- Vector/Matrix, RowIndex, ColumnIndex -> Value
--
-- A smartish wrapper around the representation to treat
-- vectors and matrices as matrices with rows and columns
-- Trying to access rows/columns of a vector more than one
-- in the other direction with throw an error
-- 
-- Handles rotations of matrices and vectors by adjusting how the rows
-- and columns map to the representation data.
-- 
-- It is recommended to use this method instead of manual table access
-- Θ(1)
function VectorOrMatrix.get(matrix, r, c)
  if matrix:isMatrix() then
    -- newly created matrices are row vectors of column vectors
    if matrix._la.direction == COLUMN then
      return matrix:access(r):access(c)
    else
      -- rotated ones are implicitly inversed
      return matrix:access(c):access(r)
    end
  else
    local vector = matrix
    if vector._la.direction == COLUMN then
      if r == 1 then
        return vector:access(c)
      else
        error("Row index " .. r .. " out of range in vector "
          .. tostring(vector), 2, debug.traceback())
      end
    else
      if c == 1 then
        return vector:access(r)
      else
        error("Column index " .. c .. " out of range in vector "
          .. tostring(vector), 2, debug.traceback())
      end
    end
  end
end

-- Vector/Matrix, RowIndex, ColumnIndex, Value -> assigns value to vector/matrix
--
-- A smartish wrapper around the representation to treat
-- vectors and matrices as matrices with rows and columns
-- Trying to access rows/columns of a vector more than one
-- in the other direction with throw an error
-- 
-- Handles rotations of matrices and vectors by adjusting how the rows
-- and columns map to the representation data.
-- 
-- It is recommended to use this method instead of manual table assignment
-- Θ(1)
function VectorOrMatrix.set(matrix, r, c, value)
  if matrix:isMatrix() then
    if matrix._la.direction == COLUMN then
      -- newly created matrices are row vectors of column vectors
      matrix:access(r):assign(c, value)
    else
      -- rotated ones are implicitly inversed
      matrix:access(c):assign(r, value)
    end
  else
    local vector = matrix
    if vector._la.direction == COLUMN then
      if r == 1 then
        vector:assign(c, value)
      else
        error("Row index " .. r .. " out of range in vector "
          .. tostring(vector), 2, debug.traceback())
      end
    else
      if c == 1 then
        vector:assign(r, value)
      else
        error("Column index " .. c .. " out of range in vector "
          .. tostring(vector), 2, debug.traceback())
      end
    end
  end
end

-- Vector/Matrix, Vector/Matrix -> Vector/Matrix
-- Θ(nmp) where the input is an n * m matrix/vector
-- and a m * p matrix/vector
-- for square matrices this is Θ(n^3) where 
-- n is count of elements in each axis
--
-- Matrix multiplication of 2 vectors, Order is important
-- as Matrix multiplication is not commutative in general
--
-- This method does not automatically transpose vectors
-- to make the multiplication defined
--
-- This is not a high performance matrix multiplication model
-- and the multiplication is directly applied from the mathematical
-- definition, with the Θ(nmp) runtime as a result.
-- Lua is not the language for high performance, find a C library and use that.
local UNDEFINED_WIKI_LINK = "https://en.wikipedia.org/wiki/Matrix_multiplication#Matrix_product_(two_matrices)"
function VectorOrMatrix.__mul(matrix1, matrix2)
  if matrix1:columns() ~= matrix2:rows() then
    error("Matrix/Vector multiplication is undefined for "
      .. tostring(matrix1) .. " and " .. tostring(matrix2) ..  " see "
      .. UNDEFINED_WIKI_LINK, 2, debug.traceback())
  end
  if matrix1:columns() == 0 or matrix1:rows() == 0
  or matrix2:columns() == 0 or matrix2:rows() == 0 then
    error("Empty Matrix/Vector" .. tostring(matrix1) .. tostring(matrix2)
      , 2, debug.traceback())
  end
  -- get resultant size
  local rows = matrix1:rows()
  local columns = matrix2:columns()
  local result = {}
  if rows == 1 or columns == 1 then
    result = vector.new(result)
    result._la.count = columns
    if rows > 1 then
      -- flip so that result is a row vector
      result = result.T()
      result._la.count = rows
      result._la.direction = ROW
    end
  else
    result = matrix.new(result)
    -- result is a matrix
    -- of column vectors
    for i = 1, rows do
      result:assign(i, vector.new({}))
      result:access(i)._la.count = columns
    end
    result._la.count = rows
  end
  -- put in values from multiplication into new vector/matrix
  for i = 1, rows do
    for j = 1, columns do
      local sum = 0
      for k = 1, matrix1:columns() do
        sum = sum + matrix1:get(i, k) * matrix2:get(k, j)
      end
      result:set(i, j, sum)
    end
  end
  return result
end

-- Vector/Matrix -> String
function VectorOrMatrix.__tostring(vector)
  if vector:isVector() then
    if vector._la.count == 1 then
      return "( " .. tostring(vector:access(1)) .. " )"
    end
    local s = "("
    for _, v in ipairs(vector) do
      s = s .. v .. ", "
    end
    -- remove final comma and space
    s = s:sub(1, -3)
    if vector._la.direction == ROW then
      return s .. ")"
    else
      return s .. ")^T"
    end
  else
    local matrix = vector
    local s = "[ "
    local rows, columns = matrix:size()
    for c = 1, columns do
      for r = 1, rows do
        s = s .. tostring(matrix:get(r, c)) .. ", "
      end
      s = s:sub(1, -3) .. "\n  "
    end
    -- remove final newline and spacing
    return s:sub(1, -4) .. " ]"
  end
end

return vectors