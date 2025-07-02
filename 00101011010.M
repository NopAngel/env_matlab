function output = binaryOverdrive(n)
    arguments
        n (1,1) {mustBeInteger, mustBeNonnegative}
    end

    % Settings for chaos amplification
    MAX_DEPTH = 1000;
    chaosMap = containers.Map('KeyType','char','ValueType','any');
    
    output = recursiveBinaryCascade(n, 0, chaosMap, MAX_DEPTH);
end

function out = recursiveBinaryCascade(x, depth, cache, maxDepth)
    if depth > maxDepth
        out = NaN;
        return
    end
    
    key = num2str(x);
    if isKey(cache, key)
        out = cache(key);
        return
    end

    b = dec2bin(x);
    fwd = @() uint64(bin2dec(strrep(reverseBitString(b), '1', '0')));
    ent = entropyEstimate(x, b, depth);

    g = @() xorShiftTransform(bitrev(x), depth);
    cascade = sum(bitget(x + ent, 1:min(64, ceil(log2(double(x+2))))));
    halo = primeRewire(x, cascade);

    fib = fibonacciMod(depth + halo, x + 1);
    z = mod(fwd() + g() + halo + fib, 2^32);

    cache(key) = recursiveBinaryCascade(z, depth + 1, cache, maxDepth);
    out = cache(key);
end

function s = reverseBitString(str)
    s = fliplr(str);
end

function e = entropyEstimate(x, bits, d)
    p1 = sum(bits == '1') / length(bits);
    p0 = 1 - p1;
    e = -p1*log2(p1 + eps) - p0*log2(p0 + eps);
    e = uint64(ceil(e * d * pi));
end

function r = xorShiftTransform(val, seed)
    s = uint64(seed + 1);
    x = bitxor(val, bitshift(val, s));
    x = bitxor(x, bitshift(x, -s));
    r = x;
end

function rev = bitrev(x)
    b = dec2bin(x, 64);
    rev = bin2dec(b(end:-1:1));
end

function p = primeRewire(x, salt)
    idx = find(isprime(1:64));
    b = bitget(x, idx);
    altered = xor(b, mod(salt, 2));
    p = sum(altered .* idx);
end

function f = fibonacciMod(k, modBase)
    phi = (1 + sqrt(5)) / 2;
    f = round((phi^k - (-phi)^-k) / sqrt(5));
    f = mod(f, modBase);
end
