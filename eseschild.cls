%vim:ft=tex
\ProvidesClass{eseschild}[2019/06/09 Poster auf der KIF]
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\LoadClass{scrartcl}

% packages
\usepackage[landscape, left=6.6mm, bottom=0.9cm, top=.3cm, right=1.25cm]{geometry}
\usepackage{qrcode}
\usepackage{xcolor}
\definecolor{esegray}{HTML}{595959}
\usepackage{montserrat}
% \usepackage{raleway}
\usepackage{fontspec}
\setmainfont[Color=esegray]{[Bungee-Regular.ttf]}
%\setmainfont{Montserrat}
% \setmainfont{Raleway}

\usepackage{background}
\backgroundsetup{scale = 0.97, angle = 0, opacity = 1.0,%
  contents = {\includegraphics[width = \paperwidth, height = \paperheight,
    keepaspectratio] {background}}}%

\usepackage{xkeyval}

% fitbox stuff
\usepackage{environ}% http://ctan.org/pkg/environ
\newdimen\fontdim%
\newdimen\upperfontdim%
\newdimen\lowerfontdim%
\newif\ifmoreiterations%
\fontdim12pt

\newbox\trialbox%
\newbox\linebox%
\global\newcount\maxbad%
\newcount\linebad%
\newcount\currenthbadness%


\makeatletter
\NewEnviron{fitbox}[2]{% \begin{fitbox}{<width>}{<height>} stuff \end{fitbox}
    % Store environment body
    \def\stuff{%
        \BODY%
    }%
    % prepare badness box
    \def\badnessbox{%
        \global\maxbad=0\relax%
        \currenthbadness=\hbadness% save old \hbadness
        \hbadness=10000000\relax% make sure, TeX reports overfull boxes
        \message{Starting measureline recursion with width #1^^J}%
        \setbox\trialbox=\vbox{%
            \hsize#1\relax%
            \fontsize{\fontdim}{1.2\fontdim}%
            \selectfont%
            \stuff\par%
            \measurelines% start recursion
        }%
%       \noindent\usebox\trialbox\par
        \hbadness=\currenthbadness% restore old \hbadness
    }
    % prepare recursion to measure line badness
    \def\measurelines{%
        \message{Iteration of measurelines^^J}%
        \begingroup%
            \setbox\linebox=\lastbox% get the last line
            \setbox0=\hbox%
            to \hsize{\unhcopy\linebox}% put the last line into box0 to provoke badness calculation
            \linebad=\the\badness\relax% \badness now reflects the last typeset box, i.e. box0
            \message{Badness: \the\badness\space\the\linebad\space with max \the\maxbad\space at Fontsize: \the\fontdim\space^^J}%
            \ifnum\linebad>\maxbad% store the maximum badness
                \global\maxbad=\linebad% Uncomment this line to ignore overfull hboxes!
            \fi%
            \ifvoid% end of recursion
                \linebox%
            \else%
                \unskip\unpenalty\measurelines% do the recursion
                \ifhmode%
                    \newline%
                \fi%
                \noindent\box\linebox% do the output
            \fi%
        \endgroup%
    }%
    % Prepare measurement box
    \def\buildbox{%
        \badnessbox% measure badness
        \setbox0\vbox{% measure height
            \hbox{%
                \fontsize{\fontdim}{1.2\fontdim}%
                \selectfont%
                \minipage{#1}%
                    \vbox{%
                        \stuff\par%
                    }%
                \endminipage%
            }%
        }%
        \message{Measured badness: \the\maxbad\space at Fontsize: \the\fontdim\space^^J}%
        \dimen@\ht0
        \advance\dimen@\dp0
        \message{Measured box height: \the\dimen@\space^^J}%
    }%
    \def\shrinkheight{%
        \loop%
            \fontdim.5\fontdim% Reduce font size by half
            \buildbox%
            \message{Shrinking, new box height: \the\dimen@\space at Fontsize: \the\fontdim\space^^J}%
        \ifdim\dimen@>#2 \repeat%
        \lowerfontdim\fontdim%
        \upperfontdim2\fontdim%
        \fontdim1.5\fontdim%
    }%
    \def\shrinkwidth{%
        \loop%
            \fontdim.5\fontdim% Reduce font size by half
            \buildbox%
        \ifnum\maxbad>10000 \repeat%
        \lowerfontdim\fontdim%
        \upperfontdim2\fontdim%
        \fontdim1.5\fontdim%
    }%
    \def\growheight{%
        \loop%
            \fontdim2\fontdim% Double font size
            \buildbox%
            \message{Growing, new box height: \the\dimen@\space at Fontsize: \the\fontdim\space^^J}%
        \ifdim\dimen@<#2 \repeat%
        \upperfontdim\fontdim%
        \lowerfontdim.5\fontdim%
        \fontdim.75\fontdim%
    }%
    \buildbox%
    % Compute upper and lower bounds
    \ifdim\dimen@>#2
        \message{Need to shrink box height: \the\dimen@\space^^J}%
        \shrinkheight%
    \else
        \message{Need to grow box height: \the\dimen@\space to target: #2^^J}%
        \growheight%
    \fi
    \message{Max font: \the\upperfontdim\space^^J}%
    \message{Min font: \the\lowerfontdim\space^^J}%
    % Potentially further reduce bounds for overfull box
    \ifnum\maxbad>10000
        \shrinkwidth%
    \fi
    \message{Max font adjusted: \the\upperfontdim\space^^J}%
    \message{Min font adjusted: \the\lowerfontdim\space^^J}%
    % Now try to find the optimum height and width
    \loop%
        \buildbox%
        \message{Height: \the\dimen@\space^^J}%
        \ifdim\dimen@>#2
            \moreiterationstrue%
            \upperfontdim\fontdim%
            \advance\fontdim\lowerfontdim%
            \fontdim.5\fontdim%
        \else
            \ifnum\maxbad>10000
                \moreiterationstrue%
                \upperfontdim\fontdim%
                \advance\fontdim\lowerfontdim%
                \fontdim.5\fontdim%
            \else
                \advance\dimen@-#2
                \ifdim\dimen@<10pt
                    \lowerfontdim\fontdim%
                    \advance\fontdim\upperfontdim%
                    \fontdim.5\fontdim%
                    \dimen@\upperfontdim%
                    \advance\dimen@-\lowerfontdim%
                    \ifdim\dimen@<.2pt
                        \moreiterationsfalse%
                    \else
                        \moreiterationstrue%
                    \fi
                \else
                    \moreiterationsfalse%
                \fi
            \fi
        \fi
    \ifmoreiterations\repeat%
    \message{Selected font: \the\fontdim\space^^J}%
    \vbox%
    to #2{\box0\hbox{}}% Typeset content
}%
\makeatother

\usepackage[hidelinks]{hyperref}




% pagestyle
\pagestyle{empty}

\makeatletter
\define@key{schild}{text}{\newcommand\schild@text{#1}}
\define@key{schild}{qr}{\newcommand\schild@qr{#1}}
\define@key{schild}{image}{\newcommand\schild@image{#1}}
\define@key{schild}{spacing}{\newcommand\schild@spacing{#1}}
\define@key{schild}{upper-height}{\def\upperheight{#1}}
\define@key{schild}{lower-height}{\def\lowerheight{#1}}
\define@key{schild}{offset-top}{\newcommand\schild@offsettop{#1}}



\newcommand{\schild}[3]{
    \let\schild@text\undefined
    \let\schild@qr\undefined
    \let\schild@image\undefined
    \let\schild@spacing\undefined
    \let\schild@offsettop\undefined
    \def\upperheight{.55}
    \def\lowerheight{.2}
    \setkeys{schild}{#1}
    \begin{minipage}[b][8.86cm][c]{8.275cm}%
        \centering
        \@ifundefined{schild@text}
          {}
          {
            \begin{minipage}{\textwidth}%
              \begin{fitbox}{7.1cm}{7.1cm}
                \centering
                \schild@text%
              \end{fitbox}
            \end{minipage}
          }
        % QR code url is 3rd argument
        \@ifundefined{schild@qr}
            {}
            {
                % qrcode
                \textcolor{esegray}{\qrcode[height=6.3cm]{\schild@qr}}
                \begin{fitbox}{6.3cm}{1cm}
                  \textcolor{esegray}{\url{\schild@qr}}
                \end{fitbox}
            }
        \@ifundefined{schild@image}
            {}
            {\includegraphics[width=7.1cm,
                              height=7.1cm,
                              keepaspectratio]{\schild@image}}
        \@ifundefined{schild@qr}
          {
            \@ifundefined{schild@image}
            {
                \@ifundefined{schild@text}
                {\hfill}{}
            }{}}{}
        % \vspace{10px}
    \end{minipage}%
    %
    \hspace{.55cm}
    %
    \begin{minipage}[b][\textheight][c]{.674\textwidth}
        \@ifundefined{schild@offsettop}
            {\vspace{0cm}}
            {\vspace{\schild@offsettop}}
        \begin{fitbox}{\textwidth}{\upperheight\textheight}
            \centering
            #2
        \end{fitbox}

        \@ifundefined{schild@spacing}
            {\vspace{0cm}}
            {\vspace{\schild@spacing}}

        \begin{fitbox}{\textwidth}{\lowerheight\textheight}
            \centering
            #3
        \end{fitbox}
    \end{minipage}

}
