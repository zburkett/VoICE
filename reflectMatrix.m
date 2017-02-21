function [matrixOut] = reflectMatrix(matrixIn)
matrixOut = zeros(size(matrixIn));
matrixOut(:,1) = matrixIn(:,1);
matDim = size(matrixIn);
count = 0;
for col = 2:matDim(2)
    tmpCol = matrixIn(:,col);
    tmpCol(1:(col-1)) = matrixIn(col,(1:(col-1)));
    matrixOut(:,col) = tmpCol;
end

