\version "2.19.36"

% Load the package, this will be redone using lyp
% Implicitly loads oll-core
\include "partial-compilation/package.ly"


% Register two alternative break sets.
% Note that break sets are shared between the partial-compilation
% and the page-layout/conditional-breaks packages.
% So if both packages are loaded into a project, and a break set
% refers to e.g. a musical source the break sets have only to be
% maintained once and can be used from both packages.

\registerBreakSet original-edition
\setBreaks original-edition line-breaks #'(3 (4 2/4) 5 13)
\setBreaks original-edition page-breaks #'(8 16 18 25 26)
\setBreaks original-edition page-turns #'(15)

\registerBreakSet manuscript
\setBreaks manuscript line-breaks #'(5 10 17 24)
\setBreaks manuscript page-breaks #'(13)

%\setClipRegion 3 4

%\setClipPageRange original-edition 2 3

\setClipPage original-edition 3

{
  \repeat unfold 40 c''2
}
