function meas_idx = fn_alignTimeStamps(t1, t2, t_thresh)

t_diffs = t2 - t1;
[val, meas_idx] = min(abs(t_diffs));

if isempty(meas_idx) || val > t_thresh
    meas_idx = nan;
end

end