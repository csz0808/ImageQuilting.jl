## Copyright (c) 2015, Júlio Hoffimann Mendes <juliohm@stanford.edu>
##
## Permission to use, copy, modify, and/or distribute this software for any
## purpose with or without fee is hereby granted, provided that the above
## copyright notice and this permission notice appear in all copies.
##
## THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
## WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
## MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
## ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
## WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
## ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
## OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

function relaxation(distance::AbstractArray, softdistance::AbstractArray,
                    cutoff::Real, softcutoff::Real)
  # patterns enabled in the training image
  enabled = !isinf(distance); npatterns = sum(enabled)

  # candidates with good overlap
  dbsize = all(distance[enabled] .== 0) ? npatterns : ceil(Int, cutoff*npatterns)
  overlapdb = selectperm(distance[:], 1:dbsize)

  # candidates in accordance with soft data
  softdbs = map(d -> sortperm(d[:]), softdistance)

  τₛ = softcutoff * (dbsize / npatterns)
  patterndb = []
  while true
    softdbsize = ceil(Int, τₛ*npatterns)

    patterndb = overlapdb
    for n=1:length(softdbs)
      softdb = softdbs[n][1:softdbsize]
      patterndb = quick_intersect(patterndb, softdb, length(distance))

      isempty(patterndb) && break
    end

    !isempty(patterndb) && break
    τₛ = min(τₛ + .1, 1)
  end

  patterndb
end

function quick_intersect(A::AbstractVector{Int}, B::AbstractVector{Int},
                         nbits::Integer)
  bitsA = falses(nbits)
  bitsB = falses(nbits)
  bitsA[A] = true
  bitsB[B] = true

  find(bitsA & bitsB)
end
