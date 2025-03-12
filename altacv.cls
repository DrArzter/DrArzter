%%%%%%%%%%%%%%%%%
% This is altacv.cls (v1.6.5, 3 Nov 2022) written by
% LianTze Lim (liantze@gmail.com).
%
%% It may be distributed and/or modified under the
%% conditions of the LaTeX Project Public License, either version 1.3
%% of this license or (at your option) any later version.
%% The latest version of this license is in
%%    http://www.latex-project.org/lppl.txt
%% and version 1.3 or later is part of all distributions of LaTeX
%% version 2003/12/01 or later.
%%%%%%%%%%%%%%%%

\NeedsTeXFormat{LaTeX2e}[1995/12/01]
\ProvidesClass{altacv}[2022/11/03 AltaCV v1.6.5, yet another alternative class for a resume/curriculum vitae.]

%% v1.1: Optionally load academicons
%% v1.4: Nope, academicons is unnecessary; fontawesome5 has \faOrcid.
\DeclareOption{academicons}{\ClassWarning{altacv}{academicons option is now obsolete and unnecessary.}}
%% v1.1.3: Choice of round/square photo
\newif\if@normalphoto
\DeclareOption{normalphoto}{\@normalphototrue}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{extarticle}}
\newif\if@raggedtwoe
\DeclareOption{ragged2e}{\@raggedtwoetrue}
\newif\if@withhyper
\DeclareOption{withhyper}{\@withhypertrue}
\ProcessOptions\relax

\LoadClass{article}
\RequirePackage{fontawesome5}
\RequirePackage{ifxetex,ifluatex}
\RequirePackage{etoolbox}
\RequirePackage{xparse}
\RequirePackage{xkeyval}
\RequirePackage{xcolor}
\RequirePackage[absolute,overlay]{textpos}
\RequirePackage{tabularx}
\RequirePackage{changepage}
\RequirePackage{tikz}
\RequirePackage[skins]{tcolorbox}
\RequirePackage{enumitem}
\setlist{leftmargin=*,labelsep=0.5em,nosep,itemsep=0.25\baselineskip,after=\vspace{0.25\baselineskip}}
\setlist[itemize]{label=\textbullet}
\RequirePackage{graphicx}
\RequirePackage{trimclip}
\RequirePackage{dashrule}
\RequirePackage{multirow,tabularx}
\RequirePackage{changepage}
% \RequirePackage{marginfix}

\setlength{\parindent}{0pt}
\newcommand{\divider}{\textcolor{body!30}{\hdashrule{\linewidth}{0.6pt}{0.5ex}}\medskip}

\newenvironment{fullwidth}{%
  \begin{adjustwidth}{}{\dimexpr-\marginparwidth-\marginparsep\relax}}
  {\end{adjustwidth}}

%% v1.3.1 \detokenize will break UTF-8 in pdflatex
%% Using alternative from https://tex.stackexchange.com/a/530911/226
\newcommand{\utffriendlydetokenize}[1]{%
\scantokens{%
  \catcode`\_=12%
%  \catcode`\^=12%
%  \catcode`\{=12%
%  \catcode`\}=12%
  \catcode`\&=12%
  \catcode`\$=12%
  \catcode`\#=12%
  \catcode`\~=12%
%  \catcode`\\=12%
  {#1}%
}%
}
%% v1.3: Incorporating hyperref
%% v1.3.1: using \unfriendlydetokenize to avoid breaking unicode
%% v1.6: Use accsupp instead here, to preserve Unicode in PDF copy text
\RequirePackage{accsupp}
\if@withhyper
  \RequirePackage{hyperref}
  \urlstyle{same}
  \renewcommand{\href}[2]{\BeginAccSupp{method=escape,ActualText={#2}}%
    \hyperref[#1]{#2}\EndAccSupp{}}
\else
  \newcommand{\href}[2]{#2}
\fi

% v1.6.5: New accsupp replacement for \NewInfoField
\newcommand{\skillat}[2]{%
\BeginAccSupp{method=escape,ActualText={#1}}
\textcolor{emphasis}{#2}\EndAccSupp{}%
}

\colorlet{accent}{blue!70!black}
\colorlet{emphasis}{black}
\colorlet{heading}{black}
\colorlet{headingrule}{black}
\colorlet{subheading}{emphasis}
\colorlet{body}{black!80!white}
\colorlet{name}{heading}
\colorlet{tagline}{accent}
\newcommand{\itemmarker}{{\small\textbullet}}
\newcommand{\ratingmarker}{\faCircle}

\RequirePackage{tikz}
\usetikzlibrary{arrows}
\RequirePackage[skins]{tcolorbox}
\RequirePackage[inline]{enumitem}
\setlist{leftmargin=*,labelsep=0.5em,nosep,itemsep=0.25\baselineskip,after=\vspace{0.25\baselineskip}}
\setlist[itemize]{label=\itemmarker}
\RequirePackage{graphicx}
\RequirePackage{etoolbox}
\RequirePackage{dashrule}
\RequirePackage{multirow,tabularx}
\RequirePackage{changepage}
% \RequirePackage{marginfix}

\RequirePackage{geometry}

\if@raggedtwoe
  \RequirePackage[newcommands]{ragged2e}
\fi

\RequirePackage{fontawesome5}

%% v1.6: Use accsupp to ensure unicode text copied correctly from PDF
\RequirePackage{accsupp}
\newcommand{\drawrating}[1]{\BeginAccSupp{method=plain,ActualText={#1}}%
\multirowcell{2}{\tikz{ \foreach \x in {1,...,5}{
\pgfmathsetmacro\fillValue{(\x <= #1 ? 1 : (\x - 0.5 == #1 ? 0.5 : 0))}
\draw[fill=accent, draw=accent!30!white, line cap=round, line width=0.8pt, rounded corners=0.5pt, fill opacity=\fillValue] ({\x - 1}, -0.1) circle (0.25);
}}}\EndAccSupp{}}

\newcommand{\cvtag}[1]{%
  \tikz[baseline]\node[draw=body!30,rounded corners,inner xsep=1ex,inner ysep =0.75ex,text height=1.5ex,text depth=.25ex]{#1};
}

\newcommand{\cvskill}[3][]{%
  \textcolor{emphasis}{\textbf{#2}} & \drawrating{#3} \\
  \ifstrequal{#1}{}{}{\textcolor{body}{#1} \\}
}

% Adapted from @Jake's answer at https://tex.stackexchange.com/a/82729/226
\newcommand{\wheelchart}[4][0]{%
    \begingroup\centering
    \def\innerradius{#3}%
    \def\outerradius{#2}%
    % Calculate total
    \pgfmathsetmacro{\totalnum}{0}%
    \foreach \value/\colour/\name in {#4} {%
        \pgfmathparse{\value+\totalnum}%
        \global\let\totalnum=\pgfmathresult%
    }%
    \begin{tikzpicture}

      % Calculate the thickness and the middle line of the wheel
      \pgfmathsetmacro{\wheelwidth}{\outerradius-\innerradius}
      \pgfmathsetmacro{\midradius}{(\outerradius+\innerradius)/2}
      \pgfmathsetmacro{\totalrot}{-90 + #1}

      % Rotate so we start from the top
      \begin{scope}[rotate=\totalrot]

      % Loop through each value set. \cumnum keeps track of where we are in the wheel
      \pgfmathsetmacro{\cumnum}{0}
      \foreach \value/\width/\colour/\name in {#4} {
            \pgfmathsetmacro{\newcumnum}{\cumnum + \value/\totalnum*360}

            % Calculate the percent value
            \pgfmathsetmacro{\percentage}{\value/\totalnum*100}
            % Calculate the mid angle of the colour segments to place the labels
            \pgfmathsetmacro{\midangle}{-(\cumnum+\newcumnum)/2}

            % This is necessary for the labels to align nicely
            \pgfmathparse{
               (-\midangle<180?"west":"east")
            } \edef\textanchor{\pgfmathresult}
            \pgfmathparse{
               (-\midangle>180?"flush left":"flush right")
            } \edef\textalign{\pgfmathresult}
            \pgfmathsetmacro\labelshiftdir{1-2*(-\midangle>180)}

            % Draw the color segments. Somehow, the \midrow units got screwed up, so we add 'pt' at the end. Not nice...
            \filldraw[draw=white,fill=\colour] (-\cumnum:\outerradius) arc (-\cumnum:-(\newcumnum):\outerradius) --
            (-\newcumnum:\innerradius) arc (-\newcumnum:-(\cumnum):\innerradius) -- cycle;

            % Draw the data labels
            % v1.6: Use accsupp so that the numeric data is copied correctly from PDF
            \draw  [*-,thin,emphasis] node [append after command={(\midangle:\midradius pt) -- (\midangle:\outerradius + 1ex) -- (\tikzlastnode)}] at (\midangle:\outerradius + 1ex) [xshift=\labelshiftdir*0.5cm,inner sep=0pt, outer sep=0pt, ,anchor=\textanchor,align=\textalign,font=\small,text width=2.5cm]{\BeginAccSupp{method=pdfstringdef,ActualText={\name: \value\%}}\name{}: {\value\%}\EndAccSupp{}};

            % Set the old cumulated angle to the new value
            \global\let\cumnum=\newcumnum
        }
      \end{scope}
%      \draw[gray] (0,0) circle (\outerradius) circle (\innerradius);
    \end{tikzpicture}\par
    \endgroup
}

\newcommand{\cvsection}[2][]{%
  \bigskip%
  \ifstrequal{#1}{}{}{\marginpar{\vspace*{\dimexpr1pt-\baselineskip}\raggedright\input{#1}}}%
  {\color{heading}\LARGE\bfseries\MakeUppercase{#2}}\\[-1ex]%
  {\color{headingrule}\rule{\linewidth}{2pt}\par}\medskip
}

\newcommand{\cvsubsection}[1]{%
  \smallskip%
  {\color{subheading}\large\bfseries{#1}\par}\medskip
}

% v1.1.4: fixes inconsistent font size
\newcommand{\cvevent}[4]{%
  {\large\color{emphasis}#1\par}
  \smallskip\normalsize
  \ifstrequal{#2}{}{}{
  \textbf{\color{accent}#2}\par
  \smallskip}
  \ifstrequal{#3}{}{}{{\small\makebox[0.5\linewidth][l]{\faCalendar~#3}}}%
  \ifstrequal{#4}{}{}{{\small\makebox[0.5\linewidth][l]{\faMapMarker*~#4}}}\par
  \medskip\normalsize
}

\newcommand{\icontext}[3]{%
  \smallskip\normalsize
  {\small\makebox[0.5\linewidth][l]{\color{accent}#1~#2}}%
  \smallskip\normalsize
  {\small\makebox[1.5\linewidth][l]{#3}}%
}

% v1.6: Use accsupp so that the academic degree is copied correctly from PDF
\newcommand{\cvdegree}[5]{
\textbf{\BeginAccSupp{method=pdfstringdef,ActualText={#1, #3, #2, #4, #5}}
#1, #2\EndAccSupp{}} \\
\ifstrequal{#3}{}{}{\textit{#3}\\}
\ifstrequal{#4}{}{}{\small\makebox[0.5\linewidth][l]{\faCalendar\hspace{0.5em}#4}}%
\ifstrequal{#5}{}{}{\small\makebox[0.5\linewidth][l]{\faMapMarker*~#5}}%
\vspace{1em}
}

\newcommand{\cvitem}[2]{%
  \textbf{\color{emphasis}#1}{: #2 \par}
}

% v1.6: Makes cvitem work with accsupp so that the academic degree is copied correctly from PDF
\newcommand{\cvitemwithcomment}[3]{%
  \begingroup
  \setbox0=\hbox{\BeginAccSupp{method=escape,ActualText={#1: #3}}#1\EndAccSupp{}}
  \setlength{\hangtabratio}{\widthof{#1}}
  \ifthenelse{\lengthtest{\hangtabratio < 4.0em}}{
    \ifthenelse{\lengthtest{\hangtabratio < 3.0em}}{
      \ifthenelse{\lengthtest{\hangtabratio < 2.0em}}{
        \ifthenelse{\lengthtest{\hangtabratio < 1.0em}}{
          \setlength{\hangtabratio}{1.0em}
        }{
          \setlength{\hangtabratio}{2.0em}
        }
      }{
        \setlength{\hangtabratio}{3.0em}
      }
    }{
      \setlength{\hangtabratio}{4.0em}
    }
  }{\setlength{\hangtabratio}{\widthof{#1}}}
  \setlength{\hangindent}{\dimexpr\hangtabratio+0.5em}
  \noindent\hangafter=1\makebox[\hangtabratio][l]{\BeginAccSupp{method=escape,ActualText={#1: #3}}{\color{emphasis}#1}\EndAccSupp{}}\hspace{0.5em}#2\\[-0.2\baselineskip]
  \ifstrequal{#3}{}{}{\smallskip\normalsize\makebox[\linewidth][r]{\footnotesize{#3}}}
  \par\endgroup\medskip
}

\newcommand{\cvachievement}[3]{%
  \begin{tabularx}{\linewidth}{@{}p{2em} @{\hspace{1ex}} >{\raggedright\arraybackslash}X@{}}
  \textcolor{accent}{#1} & #2\\\smallskip
  \end{tabularx}%
  \smallskip\begin{minipage}{\linewidth}#3\end{minipage}\medskip
}

\newcommand{\cvtag}[1]{%
  \tikz[baseline]\node[anchor=base,draw=body!30,rounded corners,inner xsep=1ex,inner ysep =0.75ex,text height=1.5ex,text depth=.25ex]{#1};
}

\newcommand{\cvlist}[1]{%
  \begin{itemize}{#1}\end{itemize}
}

% v1.6: Use accsupp so that the numeric value is copied correctly from PDF
\newenvironment{cvskills}{%
  \begin{itemize}[leftmargin=2ex, rightmargin=2ex, noitemsep]
    \setlength{\parskip}{0pt}
    \renewcommand{\item}[2]{%
      \item[{\color{accent}\BeginAccSupp{method=plain,ActualText={##1}}##1\EndAccSupp{}}] ##2
    }
}{%
  \end{itemize}
}


% Adapted from @Jake's answer at https://tex.stackexchange.com/a/82729/226
\newcommand{\wheelchart}[4][0]{%
    \begingroup\centering
    \def\innerradius{#3}%
    \def\outerradius{#2}%
    % Calculate total
    \pgfmathsetmacro{\totalnum}{0}%
    \foreach \value/\colour/\name in {#4} {%
        \pgfmathparse{\value+\totalnum}%
        \global\let\totalnum=\pgfmathresult%
    }%
    \begin{tikzpicture}

      % Calculate the thickness and the middle line of the wheel
      \pgfmathsetmacro{\wheelwidth}{\outerradius-\innerradius}
      \pgfmathsetmacro{\midradius}{(\outerradius+\innerradius)/2}
      \pgfmathsetmacro{\totalrot}{-90 + #1}

      % Rotate so we start from the top
      \begin{scope}[rotate=\totalrot]

      % Loop through each value set. \cumnum keeps track of where we are in the wheel
      \pgfmathsetmacro{\cumnum}{0}
      \foreach \value/\width/\colour/\name in {#4} {
            \pgfmathsetmacro{\newcumnum}{\cumnum + \value/\totalnum*360}

            % Calculate the percent value
            \pgfmathsetmacro{\percentage}{\value/\totalnum*100}
            % Calculate the mid angle of the colour segments to place the labels
            \pgfmathsetmacro{\midangle}{-(\cumnum+\newcumnum)/2}

            % This is necessary for the labels to align nicely
            \pgfmathparse{
               (-\midangle<180?"west":"east")
            } \edef\textanchor{\pgfmathresult}
            \pgfmathparse{
               (-\midangle>180?"flush left":"flush right")
            } \edef\textalign{\pgfmathresult}
            \pgfmathsetmacro\labelshiftdir{1-2*(-\midangle>180)}

            % Draw the color segments. Somehow, the \midrow units got screwed up, so we add 'pt' at the end. Not nice...
            \filldraw[draw=white,fill=\colour] (-\cumnum:\outerradius) arc (-\cumnum:-(\newcumnum):\outerradius) --
            (-\newcumnum:\innerradius) arc (-\newcumnum:-(\cumnum):\innerradius) -- cycle;

            % Draw the data labels
            % v1.6: Use accsupp so that the numeric data is copied correctly from PDF
            \draw  [*-,thin,emphasis] node [append after command={(\midangle:\midradius pt) -- (\midangle:\outerradius + 1ex) -- (\tikzlastnode)}] at (\midangle:\outerradius + 1ex) [xshift=\labelshiftdir*0.5cm,inner sep=0pt, outer sep=0pt, ,anchor=\textanchor,align=\textalign,font=\small,text width=2.5cm]{\BeginAccSupp{method=pdfstringdef,ActualText={\name: \value\%}}\name{}: {\value\%}\EndAccSupp{}};

            % Set the old cumulated angle to the new value
            \global\let\cumnum=\newcumnum
        }
      \end{scope}
%      \draw[gray] (0,0) circle (\outerradius) circle (\innerradius);
    \end{tikzpicture}\par
    \endgroup
}

\newcommand{\cvref}[3]{%
  \smallskip
  \textcolor{emphasis}{\textbf{#1}}\par
  \begin{description}[font=\color{accent},style=multiline,leftmargin=1.35em,align=left]
  \item[\small\normalfont\mailaddress] #2
  \item[\small\normalfont\mailaddress] #3
  \end{description}
%   \medskip
}

\newenvironment{cvcolumn}[1]{\begin{minipage}[t]{#1}\raggedright}{\end{minipage}}

\RequirePackage[fixed]{fontawesome5}
\RequirePackage{fontawesome5}

\newcommand{\datedsubsection}[2]{%
  \cvsubsection{#1 \hfill #2}%
}

\newcommand{\personality}[1]{%
  \renewcommand{\icontextxs}[2]{\divider \makebox[2em][c]{##1} \small{##2}}
  \begin{center}\normalsize#1\end{center}
}

% define macros for CV header
\newcommand{\hero}[1]{%
    \begin{center}
        {\Huge\color{accent}\textbf{#1}}
    \end{center}
}

\RequirePackage{calc}
\newcommand{\rolefont}{\fontsize{14pt}{24pt}\selectfont}
\newcommand{\header}[3]{%
  \begin{minipage}[c]{\linewidth}
    \begin{center}
    {\Huge\headingfont\color{name}\textbf{#1}}
    \vspace{0.5em}
    \begin{minipage}[c]{\linewidth}
        \begin{center}
            {\large\headingfont\color{tagline} #2}
        \end{center}
    \end{minipage}
    \end{center}
  \end{minipage}\\[1em]
}

\newcommand{\makeheader}{%
\ifundef{\@profilepic}{}{\profpic}
\header{\@name}{\@tagline}
\smallskip
\smallskip
}

\newcommand{\makecvheader}{%
  \ifundef{\@profilepic}{}{\profpic}
  \header{\@name}{\@tagline}

  \smallskip
  \justifying
  \begin{center}
    \ifundef{\@addresscity}{}{\makefield{\small\faHome}{\@addresscity}}
    \ifundef{\@mobile}{}{\makefield{\small\faMobile}{\@mobile}}
    \ifundef{\@email}{}{\makefield{\small\faAt}{\href{mailto:\@email}{\@email}}}
    \ifundef{\@homepage}{}{\makefield{\small\faGlobeEurope}{\href{https://\@homepage}{\@homepage}}}
    \ifundef{\@github}{}{\makefield{\small\faGithub}{\href{https://github.com/\@github}{\@github}}}
    \ifundef{\@gitlab}{}{\makefield{\small\faGitlab}{\href{https://gitlab.com/\@gitlab}{\@gitlab}}}
    \ifundef{\@stackoverflow}{}{\makefield{\small\faStackOverflow}{\href{https://stackoverflow.com/users/\@stackoverflow}{\@stackoverflow}}}
    \ifundef{\@linkedin}{}{\makefield{\small\faLinkedin}{\href{https://www.linkedin.com/in/\@linkedin}{\@linkedin}}}
    \ifundef{\@twitter}{}{\makefield{\small\faTwitter}{\href{https://twitter.com/\@twitter}{\@twitter}}}
    \ifundef{\@skype}{}{\makefield{\small\faSkype}{\@skype}}
    \ifundef{\@reddit}{}{\makefield{\small\faReddit}{\@reddit}}
    \ifundef{\@xing}{}{\makefield{\small\faXing}{\@xing}}
    \ifundef{\@extrainfo}{}{\makefield{\small\faInfo}{\@extrainfo}}
  \end{center}
  \smallskip
}

\def\namefont{\huge\bfseries}
\def\taglinefont{\Large\bfseries}
\def\personalinfofont{\small\bfseries}
\def\headingfont{\bfseries}

\newcommand{\name}[1]{%
  \def\@name{#1}
}
\newcommand{\tagline}[1]{%
  \def\@tagline{#1}
}
\newcommand{\personalinfo}[1]{%
  \def\@personalinfo{#1}
}

\newcommand{\email}[1]{\def\@email{#1}}
\newcommand{\phone}[1]{\def\@mobile{#1}}
\newcommand{\location}[1]{\def\@addresscity{#1}}
\newcommand{\homepage}[1]{\def\@homepage{#1}}
\newcommand{\github}[1]{\def\@github{#1}}
\newcommand{\gitlab}[1]{\def\@gitlab{#1}}
\newcommand{\stackoverflow}[1]{\def\@stackoverflow{#1}}
\newcommand{\linkedin}[1]{\def\@linkedin{#1}}
\newcommand{\twitter}[1]{\def\@twitter{#1}}
\newcommand{\skype}[1]{\def\@skype{#1}}
\newcommand{\reddit}[1]{\def\@reddit{#1}}
\newcommand{\xing}[1]{\def\@xing{#1}}
\newcommand{\extrainfo}[1]{\def\@extrainfo{#1}}
\newcommand{\quote}[1]{\def\@quote{#1}}
\newcommand{\profilepic}[1]{\def\@profilepic{#1}}

\newcommand{\profpic}{%
  \begin{center}
    \profilepic{\@profilepic}{0.6\textwidth}
  \end{center}
}

\newcommand{\makefield}[2]{\makebox[1.5em][c]{#1} #2 \hspace{1em}}

\newcolumntype{L}[1]{>{\raggedleft\let\newline\\\arraybackslash\hspace{0pt}}p{#1}}
\newcolumntype{R}[1]{>{\raggedright\let\newline\\\arraybackslash\hspace{0pt}}p{#1}}

\newcommand{\basicprofilepicstyle}[1]{
  \begin{tikzpicture}
    \node[circle,draw=headingrule,align=center,minimum size=3.8cm,
    path picture={
      \node at (path picture bounding box.center){
        \includegraphics[width=3.5cm]{#1}
      };
    }] at (0,0) {};
  \end{tikzpicture}
}

\newcommand{\roundprofilepicstyle}[1]{
  \tikz\path[fill overzoom image={#1}]circle[radius=0.5\linewidth];
}

\if@normalphoto
  \newcommand{\profilepic}[2]{%
    \begin{tikzpicture}[remember picture,overlay]
      \node[anchor=north west, inner sep=0.7cm] at ([xshift=2em, yshift=0em] current page.north west)
      {\includegraphics[width=#2]{#1}};
    \end{tikzpicture}
  }
\else
  \newcommand{\profilepic}[2]{%
    \begin{tikzpicture}[remember picture,overlay]
      \node[anchor=north west, inner sep=0.7cm] at ([xshift=2em, yshift=0em] current page.north west)
      {\roundprofilepicstyle{#1}};
    \end{tikzpicture}
  }
\fi

\newenvironment{rightcolumn}{}{}
\newenvironment{leftcolumn}{}{} 