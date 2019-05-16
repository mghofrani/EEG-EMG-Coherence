function x = removeDuplicates (x)
% removes the entailing duplicates from the
% starting points of a perturbation signal
succession = diff([1 ; x]);
x(succession<3*500) = [];
end