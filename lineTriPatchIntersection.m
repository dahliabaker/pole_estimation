function [isIntersect] = lineTriPatchIntersection( patch_ref, uLine, patch_can, patch_can_norm )%#codegen


% local variables
p1_can = patch_can(1,:)';
p2_can = patch_can(2,:)';
p3_can = patch_can(3,:)';

% do line-plane intersection
if dot(patch_can_norm,uLine) == 0% patch is parallel to patch
    isIntersect = false;
    return
end

% if not parallel, for each current patch vertex, compute intersection
% initialize output
isIntersect = false(1,3);

for iVert = 1:3

    % assign local variable
    thisVert = patch_ref(iVert,:)';% 3x1
    
    % compute intersection between line and plane containing the candidate
    % facet
    d_int = (p1_can-thisVert)' * patch_can_norm /( uLine' * patch_can_norm );
    p_int = thisVert + uLine*d_int;

    % check if intersection point is within the candiate patch bounds
    if dot(cross(p2_can-p1_can,p_int-p1_can),patch_can_norm) >= 0 && ...
       dot(cross(p3_can-p2_can,p_int-p2_can),patch_can_norm) >= 0 && ...
       dot(cross(p1_can-p3_can,p_int-p3_can),patch_can_norm) >= 0
        
        isIntersect(iVert) = true;

    end

end

% if at least 2 vertices intersect, then flag it as true
if sum(isIntersect)>2
    isIntersect = true;
else
    isIntersect = false;
end
