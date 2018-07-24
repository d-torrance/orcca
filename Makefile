## ********************************************************************* ##
## Copyright 2016-2018                                                   ##
## Portland Community College                                            ##
##                                                                       ##
## This file is part of Open Resources for Community College Algebra     ##
## (ORCCA).                                                              ##
## ********************************************************************* ##


#######################
# DO NOT EDIT THIS FILE
#######################

#   1) Make a copy of Makefile.paths.original
#      as Makefile.paths, which git will ignore.
#   2) Edit Makefile.paths to provide full paths to the root folders
#      of your local clones of the project repository and the mathbook
#      repository as described below.
#   3) The files Makefile and Makefile.paths.original
#      are managed by git revision control and any edits you make to
#      these will conflict. You should only be editing Makefile.paths.

##############
# Introduction
##############

# This is not a "true" makefile, since it does not
# operate on dependencies.  It is more of a shell
# script, sharing common configurations

######################
# System Prerequisites
######################

#   install         (system tool to make directories)
#   xsltproc        (xml/xsl text processor)
#   xmllint         (only to check source against DTD)
#   <helpers>       (PDF viewer, web browser, pager, Sage executable, etc)

#####
# Use
#####

#	A) Navigate to the location of this file
#	B) At command line:  make <some-target-from-the-options-below>

##################################################
# The included file contains customized versions
# of locations of the principal components of this
# project and names of various helper executables
##################################################
include Makefile.paths

###################################
# These paths are subdirectories of
# the project distribution
###################################
PRJSRC    = $(PRJ)/src
IMAGESSRC = $(PRJSRC)/images
OUTPUT    = $(PRJ)/output
STYLE     = $(PRJ)/style
XSL       = $(PRJ)/xsl

# The project's main hub file
MAINFILE  = $(PRJSRC)/orcca.ptx

# The project's styling files
CSS       = $(STYLE)/css/orcca.css
PRJXSL    = $(PRJ)/xsl
LATEX     = $(XSL)/orcca-latex.xsl

# These paths are subdirectories of
# the Mathbook XML distribution
# MBUSR is where extension files get copied
# so relative paths work properly
MBXSL = $(MB)/xsl
MBUSR = $(MB)/user
DTD   = $(MB)/schema/dtd

# These paths are subdirectories of the output
# folder for different output formats
PGOUT      = $(OUTPUT)/pg
HTMLOUT    = $(OUTPUT)/html
PDFOUT     = $(OUTPUT)/pdf
IMAGESOUT  = $(OUTPUT)/images
WWOUT      = $(OUTPUT)/webwork-extraction

# Some aspects of producing these examples require a WeBWorK server.
# For all but trivial testing or examples, please look into setting
# up your own WeBWorK server, or consult Alex Jordan about the use
# of PCC's server in a nontrivial capacity.    <alex.jordan@pcc.edu>
SERVER = https://webwork.pcc.edu
#SERVER = http://localhost

webwork-extraction:
	install -d $(WWOUT)
	-rm $(WWOUT) webwork-extraction.xml
	$(MB)/script/mbx -vv -c webwork -d $(WWOUT) -s $(SERVER) $(MAINFILE)

merge:
	cd $(OUTPUT); \
	xsltproc --xinclude --stringparam webwork.extraction $(WWOUT)/webwork-extraction.xml $(MBXSL)/pretext-merge.xsl $(MAINFILE) > merge.xml

pg:
	install -d $(PGOUT)
	cd $(PGOUT); \
	rm -r ORCCA; \
	xsltproc --xinclude --stringparam chunk.level 2 $(MBXSL)/pretext-ww-problem-sets.xsl $(OUTPUT)/merge.xml

pdf:
	install -d $(OUTPUT)
	install -d $(PDFOUT)
	install -d $(PDFOUT)/images
	install -d $(IMAGESOUT)
	install -d $(IMAGESSRC)
	-rm $(PDFOUT)/images/*
	-rm $(PDFOUT)/*.*
	cp -a $(IMAGESOUT) $(PDFOUT)
	cp -a $(WWOUT)/*.png $(PDFOUT)/images
	cp -a $(IMAGESSRC) $(PDFOUT)
	cd $(PDFOUT); \
	xsltproc -xinclude --stringparam latex.fillin.style box --stringparam exercise.inline.hint no --stringparam exercise.inline.answer no --stringparam exercise.inline.solution yes --stringparam exercise.divisional.hint no --stringparam exercise.divisional.answer no --stringparam exercise.divisional.solution no $(LATEX) $(OUTPUT)/merge.xml; \
	perl -pi -e 's/\\usepackage\{geometry\}//' orcca.tex; \
	perl -pi -e 's/\\documentclass\[10pt,\]\{book\}/\\documentclass\[paper=letter,DIV=14,BCOR=0.25in,chapterprefix,numbers=noenddot,fontsize=10pt,toc=indentunnumbered\]\{scrbook\}/' orcca.tex; \
	perl -pi -e 's/\\geometry\{letterpaper,total=\{340pt,9\.0in\}\}//' orcca.tex; \
	perl -pi -e 's/\%\% fontspec package will make Latin Modern \(lmodern\) the default font/\%\% Customized to load Palatino fonts\n\\usepackage[T1]{fontenc}\n\\renewcommand\{\\rmdefault\}\{zpltlf\} \%Roman font for use in math mode\n\\usepackage\[scaled=.85\]\{beramono\}\% used only by \\mathtt\n\\usepackage\[type1\]\{cabin\}\%used only by \\mathsf\n\\usepackage\{amsmath,amssymb,amsthm\}\%load before newpxmath\n\\usepackage\[varg,cmintegrals,bigdelims,varbb\]\{newpxmath\}\n\\usepackage\[scr=rsfso\]\{mathalfa\}\n\\usepackage\{bm\} \%load after all math to give access to bold math\n\% Now load the otf text fonts using fontspec--wont affect math\n\\usepackage\[no-math\]\{fontspec\}\n\\setmainfont\{TeXGyrePagellaX\}\n\\defaultfontfeatures\{Ligatures=TeX,Scale=1,Mapping=tex-text\}\n\% This is a palatino-like font\n\%\\setmainfont\[BoldFont = texgyrepagella-bold.otf, ItalicFont = texgyrepagella-italic.otf, BoldItalicFont = texgyrepagella-bolditalic.otf]\{texgyrepagella-regular.otf\}\n\\linespread\{1.02\}/' orcca.tex; \
	perl -pi -e 's/\\usepackage\{fontspec\}\n//' orcca.tex; \
	perl -pi -e 's/Checkpoint/\\includegraphics[height=1pc]{images\/webwork-logo.eps} Checkpoint/g' orcca.tex; \
	perl -pi -e 's/(after-item-skip)=\\smallskipamount,(after-skip)=\\smallskipamount/\1=0pt,\2=0pt/' orcca.tex; \
	perl -pi -e 's/(\\end{exercisegroup})\\par\\medskip\\noindent\n/\1\n/' orcca.tex; \
	echo 'In sidebyside with multiple paragraphs, need to set the parskip to match rest of the book'; \
	perl -pi -e 's/(\\begin{sbspanel}.*)/\1\n\\setlength{\\parskip}{0.5pc}/g' orcca.tex; \
	echo 'In exercisegroup, when the problem starts with a sidebyside (tabular, image), pull it upward vertically'; \
	perl -p0i -e 's/(\\exercise\[\d+\.\] \\hypertarget{exercise-\d+}{}\n)(\\begin{sidebyside})/\1\\vspace{-\\dimexpr 2\\baselineskip\\relax}%\n\2/g' orcca.tex; \
	echo 'In exercisegroup, when the problem starts with an enumerate, pull it upward vertically'; \
	perl -p0i -e 's/(\\exercise\[\d+\.\] \\hypertarget{exercise-\d+}{}\n\\hypertarget{p-\d+}{}%\n)(\\leavevmode%\n\\begin{enumerate}\[[^\]]*\]\n[^\n]*\n[^\n]*fillin)/\1\\vspace{-\\dimexpr2\\parskip+1\\baselineskip-0.4pt\\relax}%\n%\2/g' orcca.tex; \
	perl -p0i -e 's/(\\exercise\[\d+\.\] \\hypertarget{exercise-\d+}{}\n\\hypertarget{p-\d+}{}%\n)(\\leavevmode%\n\\begin{enumerate})/\1\\vspace{-\\dimexpr\\parskip+1\\baselineskip\\relax}%\n%\2/g' orcca.tex; \
	perl -p0i -e 's/(\\exercise\[\d+\.\] \\hypertarget{exercise-\d+}{}\n\\hypertarget{p-\d+}{}%\n.*?\n)\\par\n(\\hypertarget{p-\d+}{}%\n)\\leavevmode%\n(\\begin{itemize})/\1\2\3/g' orcca.tex; \
	echo 'In an inline exercise, remove the vertical spacing prior to an enumerate'; \
	perl -p0i -e 's/(\\begin{inlineexercise}.*?\\label{exercise-\d+}\n(((?!inlineexercise).)*\n)*?)\\par\n(\\hypertarget{p-\d+}{}%\n)\\leavevmode%\n(\\begin{enumerate})/\1\4\5/g' orcca.tex; \
	perl -p0i -e 's/(\\begin{inlineexercise}.*?\\label{exercise-\d+}\n(((?!inlineexercise).)*\n)*?)\\par\\medskip\n(\\hypertarget{p-\d+}{}%\n)\\leavevmode%\n(\\begin{multicols})/\1\4\5/g' orcca.tex; \
	perl -p0i -e 's/(\\begin{inlineexercise}.*?\\label{exercise-\d+}\n(((?!inlineexercise).)*\n)*?)\\par\n(\\hypertarget{p-\d+}{}%\n)\\leavevmode%\n(\\begin{multicols})/\1\4\5/g' orcca.tex; \
	echo 'In an exercisegroup exercise, remove the vertical spacing prior to an enumerate'; \
	perl -p0i -e 's/(\\exercise\[\d+\.\].*?\\hypertarget{exercise-\d+}{}\n(((?!exercise).)*\n)*?)\\par\n(\\hypertarget{p-\d+}{}%\n)\\leavevmode%\n(\\begin{enumerate})/\1\4\5/g' orcca.tex; \
	echo 'In an divisional exercise, remove the vertical spacing prior to an enumerate'; \
	perl -p0i -e 's/(\\begin{divisionexercise}.*?\\hypertarget{exercise-\d+}{}\n(((?!divisionexercise).)*\n)*?)\\par\n(\\hypertarget{p-\d+}{}%\n)\\leavevmode%\n(\\begin{enumerate})/\1\4\5/g' orcca.tex; \
	echo 'In division exercise, when the problem starts with an enumerate, pull it upward vertically'; \
	perl -p0i -e 's/(\\begin{divisionexercise}{\d+}\\hypertarget{exercise-\d+}{}\n\\hypertarget{p-\d+}{}%\n)(\\leavevmode%\n\\begin{enumerate})/\1\\vspace{-\\dimexpr\\parskip+1\\baselineskip-0.4pt\\relax}%\n%\2/g' orcca.tex; \
	echo 'Images in a multicolumn exercicegroup need their sizing adjusted to account for the narrower column'; \
	for i in {1..26}; do perl -p0i -e 's/(\\begin{exercisegroup}\(2\)\n(((?!exercisegroup).)*\n)*?\\begin{sidebyside}\{1\})\{0\.3\}\{0\.3\}\{0\}\n(\\begin{sbspanel})\{0\.4\}/\1\{0\.1\}\{0\.1\}\{0\}\n\4\{0\.8\}/g' orcca.tex; done; \
	for i in {1..26}; do perl -p0i -e 's/(\\begin{exercisegroup}\(2\)\n(((?!exercisegroup).)*\n)*?\\begin{sidebyside}\{1\})\{0\.16+7\}\{0\.16+7\}\{0\}\n(\\begin{sbspanel})\{0\.6+7\}/\1\{0\}\{0\}\{0\}\n\4\{1\}/g' orcca.tex; done; \
	for i in {1..26}; do perl -p0i -e 's/(\\begin{exercisegroup}\(3\)\n(((?!exercisegroup).)*\n)*?\\begin{sidebyside}\{1\})\{0\.3\}\{0\.3\}\{0\}\n(\\begin{sbspanel})\{0\.4\}/\1\{0\}\{0\}\{0\}\n\4\{1\}/g' orcca.tex; done ;\
	echo 'Images in a multicolumn list within a webwork exercise need their sizing adjusted to account for the narrower column'; \
	perl -p0i -e 's/(\\begin{inlineexercise}.*?\\label{exercise-\d+}\n(((?!inlineexercise).)*\n)*?\\begin{multicols}\{3\}\n(((?!multicols).)*\n)*?[^\n]*\\begin{sidebyside}\{1\})\{0\.3\}\{0\.3\}\{0\}\n(\\begin{sbspanel})\{0\.4\}/\1\{0\}\{0\}\{0\}\n\6\{1\}/g' orcca.tex; \
	perl -p0i -e 's/(\\begin{inlineexercise}.*?\\label{exercise-\d+}\n(((?!inlineexercise).)*\n)*?\\begin{multicols}\{3\}\n(((?!multicols).)*\n)*?[^\n]*\\begin{sidebyside}\{1\})\{0\.3\}\{0\.3\}\{0\}\n(\\begin{sbspanel})\{0\.4\}/\1\{0\}\{0\}\{0\}\n\6\{1\}/g' orcca.tex; \
	perl -p0i -e 's/(\\begin{inlineexercise}.*?\\label{exercise-\d+}\n(((?!inlineexercise).)*\n)*?\\begin{multicols}\{3\}\n(((?!multicols).)*\n)*?[^\n]*\\begin{sidebyside}\{1\})\{0\.3\}\{0\.3\}\{0\}\n(\\begin{sbspanel})\{0\.4\}/\1\{0\}\{0\}\{0\}\n\6\{1\}/g' orcca.tex; \
	perl -p0i -e 's/(\\begin{divisionexercise}.*?\\hypertarget{exercise-\d+}{}\n(((?!divisionexercise).)*\n)*?\\begin{multicols}\{3\}\n(((?!multicols).)*\n)*?[^\n]*\\begin{sidebyside}\{1\})\{0\.3\}\{0\.3\}\{0\}\n(\\begin{sbspanel})\{0\.4\}/\1\{0\}\{0\}\{0\}\n\6\{1\}/g' orcca.tex; \
	perl -p0i -e 's/(\\begin{divisionexercise}.*?\\hypertarget{exercise-\d+}{}\n(((?!divisionexercise).)*\n)*?\\begin{multicols}\{3\}\n(((?!multicols).)*\n)*?[^\n]*\\begin{sidebyside}\{1\})\{0\.3\}\{0\.3\}\{0\}\n(\\begin{sbspanel})\{0\.4\}/\1\{0\}\{0\}\{0\}\n\6\{1\}/g' orcca.tex; \
	perl -p0i -e 's/(\\begin{divisionexercise}.*?\\hypertarget{exercise-\d+}{}\n(((?!divisionexercise).)*\n)*?\\begin{multicols}\{3\}\n(((?!multicols).)*\n)*?[^\n]*\\begin{sidebyside}\{1\})\{0\.3\}\{0\.3\}\{0\}\n(\\begin{sbspanel})\{0\.4\}/\1\{0\}\{0\}\{0\}\n\6\{1\}/g' orcca.tex; \
	perl -pi -e 's/\\noindent$/\\noindent%/g' orcca.tex; \
	perl -pi -e 's/^(\\hypertarget{exercisegroup-\d+}{})\n/\1%\n/' orcca.tex; \
	perl -pi -e 's/^(\\subparagraph\[{.*?}\]{)(.*?}\\hypertarget{exercisegroup-\d+}{})/\1\\hspace{-1em}\2/g' orcca.tex; \
	echo 'After an aside, put line breaks in tex source.'; \
	perl -pi -e 's/(\\end{aside}\n)/\1\\leavevmode%\n\n/' orcca.tex; \
	perl -pi -e 's/(The slope of this line is +\\fillin{\d+}.%)/\\vspace{-1pc}\n\n\1/g' orcca.tex; \
	echo 'section-arithmetic-with-negative-numbers'; \
	perl -p0i -e 's/(\\typeout{\*+}\n\\typeout{Subsection 1\.1\.6 )/\\pagebreak\n\n\1/' orcca.tex; \
	perl -pi -e 's/(^.*?\\hypertarget{exercisegroup-2}{})/\\pagebreak\n\n\1/' orcca.tex; \
	perl -pi -e 's/(^.*?\\hypertarget{exercisegroup-5}{})/\\pagebreak\n\n\1/' orcca.tex; \
	echo 'section-fractions-and-fraction-arithmetic'; \
	perl -pi -e 's/(^.*\\label{example-5})/\\pagebreak\n\1/' orcca.tex; \
	echo 'section-absolute-value-and-square-root'; \
	perl -pi -e 's/(^.*?\\hypertarget{exercisegroup-19}{})/\\pagebreak\n\n\1/' orcca.tex; \
	echo 'section-order-of-operations'; \
	perl -pi -e 's/(^.*?\\label{exercise-227})/\\pagebreak\n\n\1/' orcca.tex; \
	perl -pi -e 's/(^.*?\\hypertarget{solution-249}{})/\\pagebreak\n\n\1/' orcca.tex; \
	perl -pi -e 's/(^.*?\\hypertarget{solution-254}{})/\\pagebreak\n\n\1/' orcca.tex; \
	perl -pi -e 's/(^.*?\\hypertarget{exercisegroup-26}{})/\\pagebreak\n\n\1/' orcca.tex; \
	echo 'section-comparison-symbols-and-notation-for-intervals'; \
	perl -pi -e 's/(^.*?\\label{exercise-367})/\\pagebreak\n\n\1/' orcca.tex; \
	perl -pi -e 's/(^.*?\\label{exercises-6})/\\pagebreak\n\n\1/' orcca.tex; \
	echo 'review-basic-math-review'; \
	perl -pi -e 's/(\\begin{example}.*?\\label{example-2[123456]}\n)/\1\\leavevmode\n/' orcca.tex; \
	perl -pi -e 's/(\\begin{example}.*?\\label{example-23})/\\pagebreak\n\n\1/' orcca.tex; \
	perl -pi -e 's/(^.*?\\hypertarget{exercisegroup-37}{})/\\pagebreak\n\n\1/' orcca.tex; \
	echo 'section-variables-and-evaluating-expressions'; \
	perl -pi -e 's/(^.*?\\hypertarget{solution-481}{})/\\pagebreak\n\n\1/' orcca.tex; \
	perl -pi -e 's/(^.*?\\hypertarget{solution-495}{})/\\pagebreak\n\n\1/' orcca.tex; \
	perl -pi -e 's/(\\exercise)(\[8\.\] \\hypertarget{exercise-494}{})/\1\*\2/' orcca.tex; \
	echo 'section-geometry-formulas'; \
	perl -pi -e 's/(^.*?\\label{exercise-551})/\\pagebreak\n\n\1/' orcca.tex; \
	perl -pi -e 's/(^.*?\\hypertarget{exercisegroup-51}{})/\\newpage\n\n\1/' orcca.tex; \
	perl -pi -e 's/(^.*?\\label{exercise-606})/\\pagebreak\n\n\1/' orcca.tex; \
	perl -pi -e 's/(^.*?\\label{exercise-607})/\\pagebreak\n\n\1/' orcca.tex; \
	echo 'section-equations-and-inequalities-as-true-false-statements'; \
	perl -pi -e 's/(^.*?\\hypertarget{exercisegroup-60}{})/\\pagebreak\n\n\1/' orcca.tex; \
	echo 'section-solving-one-step-equations'; \
	perl -pi -e 's/(^.*?\\hypertarget{exercisegroup-67}{})/\\pagebreak\n\n\1/' orcca.tex; \
	echo 'section-percentages'; \
	perl -pi -e 's/(\\begin{example}.*?\\label{example-62}\n)/\1\\leavevmode\n/' orcca.tex; \
	perl -pi -e 's/(\\begin{example}.*?\\label{example-high-school-classes}\n)/\1\\leavevmode\n/' orcca.tex; \
	perl -pi -e 's/(\\begin{example}.*?\\label{example-65}\n)/\1\\leavevmode\n/' orcca.tex; \
	perl -p0i -e 's/(\\subparagraph\[{Basic Percentage Calculation.*?\n\\begin{exercisegroup})/\1\[after-item-skip=\\dimexpr\\smallskipamount-3pt\]/' orcca.tex; \
	echo 'section-modeling-with-equations-and-inequalities'; \
	perl -pi -e 's/(^.*?\\hypertarget{exercisegroup-77}{})/\\pagebreak\n\n\1/' orcca.tex; \
	echo 'section-simplifying-expressions'; \
	perl -pi -e 's/(^.*?solution-1096})/\\pagebreak%\n\n\1/' orcca.tex; \
	perl -pi -e 's/(\\begin{divisionexercise}\{51\}\\hypertarget{exercise-1097}{})/\\pagebreak\n\n\1/' orcca.tex; \
	perl -pi -e 's/(^.*?\\hypertarget{exercisegroup-89}{})/\\pagebreak\n\n\1/' orcca.tex; \
	echo 'review-variables-expressions-and-equations'; \
	perl -pi -e 's/(\\hypertarget{exercisegroup-95}{}%)/\\newpage\n\n\1/' orcca.tex; \
	perl -pi -e 's/(\\hypertarget{exercisegroup-98}{}%)/\\newpage\n\n\1/' orcca.tex; \
	echo 'section-solving-multistep-linear-equations'; \
	perl -p0i -e 's/(\\begin{namedlist}\n\\begin{namedlistcontent}\n\\leavevmode%\n\\begin{itemize}\[label=\\textbullet\]\n\\item{}\\hypertarget{p-\d+}{}%\nAn expression like)/\\pagebreak%\n\n\1/' orcca.tex; \
	perl -pi -e 's/(^\\exercise)(\[69\.\] \\hypertarget{exercise-1285}{})/\1\*\2/' orcca.tex; \
	perl -pi -e 's/(^\\exercise)(\[70\.\] \\hypertarget{exercise-1286}{})/\1\*\2/' orcca.tex; \
	perl -p0i -e 's/\\hypertarget{p-13681}{}%\nSolve the equation\.%\n//' orcca.tex; \
	perl -pi -e 's/(^.*?\\hypertarget{exercisegroup-103}{})/\\pagebreak\n\n\1/' orcca.tex; \
	perl -pi -e 's/(^.*?\\hypertarget{exercisegroup-107}{})/\\pagebreak\n\n\1/' orcca.tex; \
	perl -pi -e 's/(^.*?\\hypertarget{exercisegroup-108}{})/\\pagebreak\n\n\1/' orcca.tex; \
	perl -pi -e 's/(^.*?\\hypertarget{exercisegroup-110}{})/\\pagebreak\n\n\1/' orcca.tex; \
	echo 'section-linear-equations-and-inequalities-with-fractions'; \
	perl -pi -e 's/(^.*?solution-1479})/\\pagebreak%\n\n\1/' orcca.tex; \
	perl -pi -e 's/(^.*?solution-1481})/\\pagebreak%\n\n\1/' orcca.tex; \
	perl -pi -e 's/(^.*?exercises-21})/\\pagebreak%\n\n\1/' orcca.tex; \
	perl -p0i -e 's/(\\hypertarget{exercisegroup-118}{}%\\hypertarget{p-\d+}{}%\n)Solve the equation\.%\n/\1/' orcca.tex; \
	perl -p0i -e 's/(\\hypertarget{exercisegroup-119}{}%\\hypertarget{p-\d+}{}%\n)Solve the equation\.%\n/\1/' orcca.tex; \
	perl -p0i -e 's/(\\hypertarget{exercisegroup-122}{}%\n\\hypertarget{p-]d+}{}%\n)Solve this inequality\.%\n/\1/' orcca.tex; \
	echo 'section-isolating-a-linear-variable'; \
	perl -p0i -e 's/(\\hypertarget{exercisegroup-126}{}%\n\\hypertarget{p-\d+}{}%\nSolve the linear equation for .*?\n\\begin{exercisegroup})/\1\[after-skip=0pt,after-item-skip=\\dimexpr\\smallskipamount-8pt\]/' orcca.tex; \
	echo 'section-ratios-and-proportions'; \
	perl -p0i -e 's/(\\subparagraph\[{Setting Up Ratios and Proportions}\].*?\n\\begin{exercisegroup})/\1\[after-item-skip=\\dimexpr\\smallskipamount-8pt\]/' orcca.tex; \
	echo 'section-special-solution-sets'; \
	perl -p0i -e 's/\\hypertarget{p-16368}{}%\nSolve the equation\.%\n//' orcca.tex; \
	perl -p0i -e 's/\\hypertarget{p-16458}{}%\nSolve this inequality\. Answer using interval notation\.%\n//' orcca.tex; \
	echo 'section-cartesian-coordinate-system'; \
	perl -pi -e 's/(Assume each unit in the grid represents one city block.%\n)/\1\\leavevmode%\n\n/' orcca.tex; \
	perl -pi -e 's/(In a Cartesian coordinate system, the map of Carl.s neighborhood would look like this:%\n)/\1\\leavevmode%\n\n/' orcca.tex; \
	perl -pi -e 's/(^.*?exercises-26})/\\pagebreak%\n\n\1/' orcca.tex; \
	perl -pi -e 's/\\href{(http:\/\/wdfw\.wa\.gov\/publications\/01793\/wdfw01793\.pdf)}{http:\/\/wdfw\.wa\.gov\/publications\/01793\/wdfw01793\.pdf}/\\url{\1}/' orcca.tex; \
	perl -pi -e 's/\\href{(http:\/\/www\.pewhispanic\.org\/2015\/09\/28\/chapter-5-u-s-foreign-born-population-trends\/)}{http:\/\/www\.pewhispanic\.org\/2015\/09\/28\/chapter-5-u-s-foreign-born-population-trends\/}/\\url{\1}/' orcca.tex; \
	perl -pi -e 's/( \(Source: \\url)/\\\\\1/' orcca.tex; \
	perl -p0i -e 's/(\\subparagraph\[{Creating Sketches of Graphs}\].*?\n\\begin{exercisegroup})/\1\[after-item-skip=\\dimexpr\\smallskipamount-8pt\]/' orcca.tex; \
	perl -p0i -e 's/(\\subparagraph\[{Regions in the Cartesian Plane}\].*?\n\\begin{exercisegroup})/\1\[after-item-skip=-1pc,after-skip=-1pc\]/' orcca.tex; \
	perl -p0i -e 's/(\\subparagraph\[{Plotting Points and Choosing a Scale}\].*?\n\\begin{exercisegroup})/\1\[after-item-skip=-1pc,after-skip=0pt\]/' orcca.tex; \
	echo 'section-graphing-equations'; \
	perl -p0i -e 's/(\\begin{exercisegroup})(\(2\)\n\\exercise\[9\.\] \\hypertarget{exercise-1722}{})/\1\[after-item-skip=\\dimexpr\\smallskipamount-7pt\]\2/' orcca.tex; \
	echo 'section-exploring-two-variable-data-and-rates-of-change'; \
	perl -pi -e 's/(^.*?\\label{exercise-1789})/\\pagebreak\n\n\1/' orcca.tex; \
	perl -p0i -e 's/(\\hypertarget{exercisegroup-149}{}%\n.*?\n.*?\n\\begin{exercisegroup})/\1\[after-item-skip=0pt,after-skip=0pt\]/' orcca.tex; \
	perl -p0i -e 's/(\\subparagraph[{Linear Relationships}].*?\\hypertarget{exercisegroup-150}{}\n.*?\n.*?\n.*?\n.*?\n.*?\n.*?\n.*?\n.*?\n.*?\n.*?\n.*?\n\\begin{exercisegroup})/\1\[after-item-skip=0pt,after-skip=0pt\]/' orcca.tex; \
	perl -pi -e 's/(^.*?\\hypertarget{exercisegroup-151}{})/\\pagebreak\n\n\1/' orcca.tex; \
	echo 'section-slope'; \
	perl -p0i -e 's/(\\subparagraph\[{Slope and Graphs}\]{\\hspace{-1em}Slope and Graphs}\\hypertarget{exercisegroup-154}{}\n\\begin{exercisegroup})/\1\[after-item-skip=\\dimexpr\\smallskipamount-8pt,after-skip=\\dimexpr\\smallskipamount-8pt\]/' orcca.tex; \
	perl -p0i -e 's/(\\begin{multicols}\{3\}\n\\begin{enumerate}\[label=\\alph\*\.\]\n\\item\\hypertarget{li-\d+}{}\\hypertarget{p-\d+}{}%\nThe first segment has slope  \\fillin\{10\}\.%)/\\vspace{-4pc}%\n\n\1/' orcca.tex; \
	perl -pi -e 's/^ \\fillin{\d+}%/%/g' orcca.tex; \
	perl -pi -e 's/(^.*?\\label{exercise-1790})/\\pagebreak\n\n\1/' orcca.tex; \
	perl -pi -e 's/(^.*?\\hypertarget{exercisegroup-154}{})/\\pagebreak\n\n\1/' orcca.tex; \
	perl -pi -e 's/(^.*?\\label{exercise-1849})/\\leavevmode\n\n\1/' orcca.tex; \
	perl -pi -e 's/(\\subparagraph\[{Challenge}\]{\\hspace{-1em}Challenge}\\hypertarget{exercisegroup-157}{})/\\vspace{-2.5pc}\n\n\1/' orcca.tex; \
	echo 'section-slope-intercept-form'; \
	perl -pi -e 's/(However, the rates of change are calculated as follows:)\\leavevmode%/\1/' orcca.tex; \
	perl -p0i -e 's/(\\begin{equation\*}\n\\frac{\\Delta y}{\\Delta x}=\\frac{41000-27500})/\\vspace{-2\.5pc}\n\n\1/' orcca.tex; \
	perl -p0i -e 's/(\\begin{equation\*}\ny=3\.85)/\\vspace{-1pc}\n\n\1/' orcca.tex; \
	perl -pi -e 's/(^.*?\\hypertarget{exercisegroup-160}{})/\\pagebreak\n\n\1/' orcca.tex; \
	perl -p0i -e 's/(\\subparagraph\[{Writing a Slope-Intercept Equation Given Two Points}\].*?\\hypertarget{exercisegroup-163}{}\n\\begin{exercisegroup})/\\vspace{-2pc}\n\n\1\[after-item-skip=-1pc\]/' orcca.tex; \
	perl -pi -e 's/(^.*?\\hypertarget{exercisegroup-165}{})/\\pagebreak\n\n\1/' orcca.tex; \
	echo 'section-point-slope-form'; \
	perl -pi -e 's/(^.*?\\label{exercise-point-slope})/\\pagebreak\n\n\1/' orcca.tex; \
	perl -pi -e 's/(^.*?\\hypertarget{solution-2114}{})/\\pagebreak\n\n\1/' orcca.tex; \
	perl -pi -e 's/(^.*?\\hypertarget{exercisegroup-167}{})/\\pagebreak\n\n\1/' orcca.tex; \
	perl -p0i -e 's/(^.*?\\hypertarget{exercisegroup-169}{}\n.*?\n.*?\n.*?\n\\begin{exercisegroup})/\\pagebreak\n\n\1\[after-item-skip=-2pc\]/' orcca.tex; \
	echo 'section-standard-from'; \
	perl -pi -e 's/(^.*?\\label{exercises-32})/\\pagebreak\n\n\1/' orcca.tex; \
	perl -p0i -e 's/(.*?\\hypertarget{exercisegroup-176}{}\n\\begin{exercisegroup})/\1\[after-item-skip=-1pc\]/' orcca.tex; \
	echo 'section-horizontal-vertical-parallel-and-perpendicular-lines'; \
	perl -pi -e 's/(.*?\\hypertarget{paragraphs-45}{}\n/\1\\leavevmode%\n/' orcca.tex; \
	perl -p0i -e 's/(.*?\\hypertarget{exercisegroup-180}{}\n\\begin{exercisegroup})/\1\[after-item-skip=-1pc,after-skip=-1pc\]/' orcca.tex; \
	perl -pi -e 's/(^.*?\\hypertarget{exercisegroup-184}{})/\\pagebreak\n\n\1/' orcca.tex; \
	echo 'review-graphing-lines'; \
	perl -pi -e 's/(^.*?\\hypertarget{solution-2340}{})/\\pagebreak\n\n\1/' orcca.tex; \
	xelatex orcca.tex; \
	xelatex orcca.tex

#  HTML output
#  Output lands in the subdirectory:  $(HTMLOUT)
html:
	install -d $(OUTPUT)
	install -d $(HTMLOUT)
	install -d $(HTMLOUT)/images
	install -d $(IMAGESOUT)
	install -d $(IMAGESSRC)
	-rm $(HTMLOUT)/*.html
	-rm $(HTMLOUT)/knowl/*.html
	-rm $(HTMLOUT)/images/*
	-rm $(HTMLOUT)/*.css
	cp -a $(IMAGESOUT) $(HTMLOUT)
	cp -a $(IMAGESSRC) $(HTMLOUT)
	cp -a $(WWOUT)/*.png $(HTMLOUT)/images
	cp $(CSS) $(HTMLOUT)
	cd $(HTMLOUT); \
	xsltproc -xinclude --stringparam exercise.inline.hint no --stringparam exercise.inline.answer no --stringparam exercise.inline.solution yes --stringparam exercise.divisional.hint no --stringparam exercise.divisional.answer no --stringparam exercise.divisional.solution no --stringparam exercise.text.hint no --stringparam exercise.text.answer no --stringparam exercise.text.solution no --stringparam html.knowl.exercise.inline no --stringparam html.knowl.example no --stringparam html.css.extra orcca.css $(PRJXSL)/orcca-html.xsl $(OUTPUT)/merge.xml

# make all the image files in svg format
images:
	install -d $(OUTPUT)
	install -d $(IMAGESOUT)
	-rm $(IMAGESOUT)/*.svg
	$(MB)/script/mbx -c latex-image -f svg -d $(IMAGESOUT) $(OUTPUT)/merge.xml
#	$(MB)/script/mbx -c asymptote -f svg -d $(IMAGESOUT) $(OUTPUT)/merge.xml

# run this to scrape thumbnail images from YouTube for any YouTube videos
youtube:
	install -d $(OUTPUT)
	install -d $(IMAGESOUT)
	-rm $(IMAGESOUT)/*.jpg
	$(MB)/script/mbx -c youtube -d $(IMAGESOUT) $(MAINFILE)


###########
# Utilities
###########

# Verify Source integrity
#   Leaves "dtderrors.txt" in OUTPUT
#   can then grep on, e.g.
#     "element XXX:"
#     "does not follow"
#     "Element XXXX content does not follow"
#     "No declaration for"
#   Automatically invokes the "less" pager, could configure as $(PAGER)
check:
	install -d $(OUTPUT)
	-rm $(OUTPUT)/jingreport.txt
	-java -classpath ~/jing-trang/build -Dorg.apache.xerces.xni.parser.XMLParserConfiguration=org.apache.xerces.parsers.XIncludeParserConfiguration -jar ~/jing-trang/build/jing.jar $(MB)/schema/pretext.rng $(MAINFILE) > $(OUTPUT)/jingreport.txt
	less $(OUTPUT)/jingreport.txt

gource:
	install -d $(OUTPUT)
	-rm $(OUTPUT)/gource.mp4
	-gource --user-filter 'Stephen Simonds' --title ORCCA --key --background-image src/images/orca3.png --user-image-dir .git/avatar/ --hide filenames --seconds-per-day 0.2 --auto-skip-seconds 1 -1280x720 -o - | ffmpeg -y -r 60 -f image2pipe -vcodec ppm -i - -vcodec libx264 -preset veryslow -pix_fmt yuv420p -crf 23 -threads 0 -bf 0 $(OUTPUT)/gource.mp4
	-mv gource.mp4 $(OUTPUT)/gource.mp4
    
