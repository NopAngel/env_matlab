function result = binaryFieldChaos(vec)
    arguments
        vec (1,:) {mustBeInteger, mustBeNonnegative}
    end

    entropyVector = zeros(size(vec));
    mutationMatrix = zeros(length(vec));

    for i = 1:length(vec)
        b = dec2bin(vec(i), 32);
        entropyVector(i) = localEntropy(b);
        for j = 1:length(vec)
            mutationMatrix(i, j) = binaryVectorMutator(vec(i), vec(j), i + j);
        end
    end

    result.entropy = entropyVector;
    result.mutation = mutationMatrix;
    result.collapse = sum(entropyVector) + trace(mutationMatrix);
end

function e = localEntropy(bits)
    onesCount = sum(bits == '1');
    p1 = onesCount / length(bits);
    p0 = 1 - p1;
    e = -p1 * log2(p1 + eps) - p0 * log2(p0 + eps);
end

function v = binaryVectorMutator(a, b, s)
    x = bitxor(a, b);
    shift = mod(s, 16);
    x = bitrotate(x, shift);
    v = mod(sum(double(dec2bin(x) == '1')) * s, 1337);
end

function r = bitrotate(x, s)
    binStr = dec2bin(x, 32);
    s = mod(s, 32);
    rotated = [binStr(end-s+1:end), binStr(1:end-s)];
    r = bin2dec(rotated);
end
