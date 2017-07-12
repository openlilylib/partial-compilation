%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                             %
% This file is part of openLilyLib,                                           %
%                      ===========                                            %
% the community library project for GNU LilyPond                              %
% (https://github.com/openlilylib)                                            %
%              -----------                                                    %
%                                                                             %
% Package: partial-compilation                                                %
%          ===================                                                %
%                                                                             %
% openLilyLib is free software: you can redistribute it and/or modify         %
% it under the terms of the GNU General Public License as published by        %
% the Free Software Foundation, either version 3 of the License, or           %
% (at your option) any later version.                                         %
%                                                                             %
% openLilyLib is distributed in the hope that it will be useful,              %
% but WITHOUT ANY WARRANTY; without even the implied warranty of              %
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               %
% GNU General Public License for more details.                                %
%                                                                             %
% You should have received a copy of the GNU General Public License           %
% along with openLilyLib. If not, see <http://www.gnu.org/licenses/>.         %
%                                                                             %
% openLilyLib is maintained by Urs Liska, ul@openlilylib.org                  %
% and others.                                                                 %
%       Copyright Urs Liska, 2016                                             %
%                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Implicitly load the breaks package
\loadPackage breaks

\addEdition partial-compilation

% Define (and activate) a clipping range.
% Only this range is typeset and compiled.
% Expect warnings about incomplete ties, dynamics etc. or other warnings/errors.
% If one of the arguments is out of range it is simply ignored
% (if #to is greater than the number of measures in the score
%  the score is engraved to the end).
setClipRegion =
#(define-void-function (from to) (edition-engraver-moment? edition-engraver-moment?)
   (let ((clip-region-from
          (if (integer? from)
              (list from #{ 0/4 #})
              (list (car from)
                (ly:make-moment (numerator (cadr from))(denominator (cadr from))))))
         (clip-region-to
          (if (integer? to)
              (list (+ 1 to) #{ 0/4 #})
              (list (car to)
                (ly:make-moment (numerator (cadr to))(denominator (cadr to)))))))
     #{
       \editionMod partial-compilation 1 0/4 breaks.Score.A
       \set Score.skipTypesetting = ##t
       \editionMod partial-compilation #(car clip-region-from) #(cadr clip-region-from) breaks.Score.A
       \set Score.skipTypesetting = ##f
       \editionMod partial-compilation #(car clip-region-to) #(cadr clip-region-to) breaks.Score.A
       \set Score.skipTypesetting = ##t
     #}))

% define (and activate) a page range to be compiled alone.
% Pass first and last page as integers.
% Several validity checks are performed.
setClipPageRange =
#(define-void-function (break-set from to)
   (symbol? integer? integer?)

   ;
   ; TODO:
   ; Merge page breaks and page turns
   ; and sort them properly!
   ;
   (let* ((page-breaks (getOption `(breaks break-sets ,break-set page-breaks)))
          (page-count (+ 1 (length page-breaks))))
     (format #t "~a\n" page-breaks)
     (if (= 1 page-count)
         (oll:warn "\\setClipPageRange requested, but no original page breaks defined. 
Continuing by compiling the whole score.")
         ;; We do have page breaks so continue by retrieving barnumbers from that list
         (cond
          ((> from to)
           (oll:warn "\\setClipPageRange: Negative page range requested. 
Continuing by compiling the whole score.~a" ""))
          ((< from 1)
           (oll:warn "\\setClipPageRange: Page number below 1 requested. 
Continuing by compiling the whole score.~a" ""))
          ((> to page-count)
           (oll:warn "\\setClipPageRange: Page index out of range (~a). 
Continuing by compiling the whole score."
             (format "from ~a to ~a requested, ~a available" from to page-count)))
          (else
           (let ((from-bar (if (eq? from 1)
                               ;; First page is not included in the originalPageBreaks list
                               ;; so we set the barnumber to 1
                               1
                               (list-ref page-breaks (- from 2))))
                 (to-bar (if (eq? to (+ (length page-breaks) 1))
                             ;; There is no page break *after* the last page,
                             ;; so we just set the "to" barnumber to -1
                             ;; because this simply discards the argument and compiles through to the end
                             -1
                             ;; Otherwise we look up the barnumber for the page break and subtract 1
                             ;; (the last measure to be included is the last one from the previous page
                             (- (list-ref page-breaks (- to 1)) 1))))
             (setClipRegion from-bar to-bar)))))))

% Define (and activate) a page to be compiled alone.
% Only that page is typeset
setClipPage =
#(define-void-function (break-set page) (symbol? integer?)
   (setClipPageRange break-set page page))
