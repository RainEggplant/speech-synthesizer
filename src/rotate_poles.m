% 返回旋转后的极点组成的多项式的系数
% a: 原极点多项式
% a: 旋转角度
function a_rotated = rotate_poles(a, rot_angle)
    poles = roots(a);
    new_poles = arrayfun(...
        @(p) p*exp(rot_angle * sign(imag(p)) * 1j), ...
        poles);
    a_rotated = poly(new_poles)*a(1); % times coefficient
end