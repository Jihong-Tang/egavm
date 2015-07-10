#!/usr/bin/env bash

echo " - Linuxbrew environment -"

echo " + Clone latest linuxbrew"
git clone https://github.com/Homebrew/linuxbrew.git ~/.linuxbrew

if grep -q -i linuxbrew ~/.bashrc; then
    echo " + .bashrc already contains linuxbrew"
else
    echo " + Update .bashrc"

    LB_PATH='export PATH="$HOME/.linuxbrew/bin:$PATH"'
    LB_MAN='export MANPATH="$HOME/.linuxbrew/share/man:$MANPATH"'
    LB_INFO='export INFOPATH="$HOME/.linuxbrew/share/info:$INFOPATH"'
    echo '# Linuxbrew' >> ~/.bashrc
    echo $LB_PATH >> ~/.bashrc
    echo $LB_MAN  >> ~/.bashrc
    echo $LB_INFO >> ~/.bashrc
    echo >> ~/.bashrc

    eval $LB_PATH
    eval $LB_MAN
    eval $LB_INFO
fi

echo " + Check brew with doctor"
brew doctor

echo " + Add tap science"
brew tap homebrew/science

echo " + Install bioinfomatics softwares"
brew install clustal-w hmmer lastz mafft newick-utils raxml
brew install blast --without-check # this will not install boost
brew install rmblast --without-blast
brew install repeatmasker --without-configure # run config later

echo " + Install vcftools"
brew install vcftools --with-zlib
cp $HOME/.linuxbrew/lib/perl5/site_perl/FaSlice.pm  `perl -e 'print grep {/site_perl/} grep {!/x86_64/} @INC'`
cp $HOME/.linuxbrew/lib/perl5/site_perl/Vcf.pm      `perl -e 'print grep {/site_perl/} grep {!/x86_64/} @INC'`
cp $HOME/.linuxbrew/lib/perl5/site_perl/VcfStats.pm `perl -e 'print grep {/site_perl/} grep {!/x86_64/} @INC'`