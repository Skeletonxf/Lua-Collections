-- wrapper
local vectors = {
  _VERSION = "Vectors and Matrices 0.1",
  _DESCRIPTION = "TODO",
  _LICENSE = "MPL2 License"
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
  -- signify as vector
  values.vector = true
  -- flag for direction of this vector
  -- column signifies a column vector when true
  -- when false this vector is a row vector
  if values._column == nil then
    values._column = true
  end
  -- tracks how many values are in this vector
  values._count = values._count or table.maxn(values)
  return values
end

-- TODO
function matrix.new(values)
  -- TODO Check values are not malformed
  local result = vector.new(values)
  result.vector = false
  result.matrix = true
  -- _count tracks how many column vectors are in this row matrix
  return result
end

-- Vector -> Vector
-- Flips rows for columns
-- Θ(1) as just flips marker
function VectorOrMatrix.T(vector)
  if not vector.vector then
    error("Attempt to transpose non vector type", 2, debug.traceback())
  end
  vector._column = not vector._column
  return vector  
end

-- aliases
VectorOrMatrix.t = vector.T
VectorOrMatrix.transpose = vector.T
VectorOrMatrix.rotate = vector.T

-- Vector -> Int (Euclidean length
-- Θ(n) where n is size of vector
function VectorOrMatrix.__len(vector)
  return VectorOrMatrix.pnorm(vector, 2)
end

-- aliases
VectorOrMatrix.length = vector.__len
VectorOrMatrix.euclidean = vector.__len

VectorOrMatrix.manhattan = function(v) return vector.pnorm(v, 1) end

-- Vector, ℕ -> Number (length of vector in this p-norm)
-- 2 is Euclidean distance, and the usual vector length
-- 1 gives Manhattan distance
-- https://en.wikipedia.org/wiki/Lp_space
-- Θ(n) where n is size of vector
function VectorOrMatrix.pnorm(vector, p)
  if not vector.vector then
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

-- Vector/Matrix -> ℕ (number of rows in vector/matrix)
-- O(1)
function VectorOrMatrix.rows(matrix)
  if matrix.matrix then
    return matrix._count
  end
  local vector = matrix
  if vector._column then
    if vector[1] then
      return 1
    else
      return 0
    end
  else
    return vector._count
  end
end

-- Vector/Matrix -> ℕ (number of columns in vector/matrix)
-- O(1)
function VectorOrMatrix.columns(matrix)
  if matrix.matrix then
    if matrix[1] then
      -- matrix is several rows of column vectors
      -- which are the same size
      return matrix[1].columns()
    else
      return 0
    end
  end
  if vector._column then
    return vector._count
  else
    if vector[1] then
      return 1
    else
      return 0
    end
  end
end

-- Vector/Matrix -> ℕ, ℕ (number of rows and columns in vector/matrix respectively)
-- O(1)
function VectorOrMatrix.size(matrix)
  return matrix.rows(), matrix.columns()
end

-- TODO
function VectorOrMatrix.get(matrix, r, c)
  if matrix.matrix then
    return matrix[r][c]
  else
    local vector = matrix
    if vector.column then
      if r == 1 then
        return vector[c]
      else
        error("TODO", 2, debug.traceback())
      end
    else
      if c == 1 then
        return vector[r]
      else
        error("TODO", 2, debug.traceback())
      end
    end
  end
end

-- TODO
function VectorOrMatrix.set(matrix, r, c, value)
  if matrix.matrix then
    matrix[r][c] = value
  else
    local vector = matrix
    if vector.column then
      if r == 1 then
        vector[c] = value
      else
        error("TODO", 2, debug.traceback())
      end
    else
      if c == 1 then
        vector[r] = value
      else
        error("TODO", 2, debug.traceback())
      end
    end
  end
end

-- Vector/Matrix, Vector/Matrix -> Vector/Matrix
-- Θ(nmp) where the input is an n * m matrix/vector
-- and a m * p matrix/vector, for square matrices
-- this is Θ(n^3) where n is count of elements in each axis
--
-- Matrix multiplication of 2 vectors
-- Order is important in as Matrix multiplication
-- is not commutative in general
--
-- This method does not automatically transpose vectors
-- to make the multiplication defined
--
-- This is not a high performance matrix multiplication model
-- and the multiplication is directly applied from the mathematical
-- definition, with the Θ(nmp) runtime as a result.
-- Lua is not the language for high performance matrix multiplication,
-- find a C library and use that.
local UNDEFINED_WIKI_LINK = "https://en.wikipedia.org/wiki/Matrix_multiplication#Matrix_product_(two_matrices)"
function vector.__mul(matrix1, matrix2)
  if matrix1.columns() ~= matrix2.rows() then
    error("Matrix/Vector multiplication is undefined for "
      .. matrix1 .. " and " .. matrix2 ..  " see "
      .. UNDEFINED_WIKI_LINK, 2, debug.traceback())
  end
  if matrix1.columns() == 0 or matrix2.rows() == 0 then
    error("Empty", 2, debug.traceback()) -- TODO
  end
  -- get resultant size
  local rows = matrix1.rows()
  local columns = matrix2.columns()
  local result = {}
  if rows == 1 or columns == 1 then
    result = vector.new(result)
    result._count = columns
    if rows > 1 then
      -- flip so that result is a row vector
      result = result.T()
      result._count = rows
    end
  else
    result = matrix.new(result)
    -- result is a matrix
    -- of column vectors
    for i = 1, rows do
      result[i] = vector.new({})
      result[i]._count = columns
    end
    result._count = rows
  end
  -- put in values from multiplication into new vector/matrix
  for i = 1, rows do
    for j = 1, columns do
      local sum = 0
      for k = 1, matrix1.columns() do
        sum = sum + matrix1:get(i, k) * matrix2:get(k, j)
      end
      result:set(i, j, sum)
    end
  end
  return result
end

return vectors