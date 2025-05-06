function obj = FromBaff(filepath,loc)
% write default items
Qty = h5readatt(filepath,[loc,'/'],'Qty');
if Qty == 0
    obj = baff.Mass.empty;
    return;
end
for i = 1:Qty
    obj(i) = baff.Mass(0);
end
BaffToProp(obj,filepath,loc);
end

