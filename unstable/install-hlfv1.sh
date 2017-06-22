ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.8.0
docker tag hyperledger/composer-playground:0.8.0 hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.hfc-key-store
tar -cv * | docker exec -i composer tar x -C /home/composer/.hfc-key-store

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� ��KY �=M��Hv=3���eG�1�\fb{wz } 5S#@TP����1R!�%�U�������_��÷=nl��/�a�����u�3%A�!�������ut�/?_����˗�rZa�虆æ&�[��וȸ�={ p\2q����@�X��P4�Y�����P�3@>P��B�v$�g�%T{5�]���0����>xN?'ZU��>A �	k}ǿtGRuh�u����n�ړZ(�=6��A���$fI���a9�W% a�<A&�}��s7��2�ԝ	R�T8-U�J=]*���k?�W�o �ؔ���6t�ԩe4U��A��5���ʡ/fKȋ�6�̔\�Ayx&V���ɖ-��M`����C�Pr������rv��$����m=8��h�ݔ�%l�˕�=h�T�!ɥ\�R��V���BX��D��p/Z�)�G�~�I=S�ԭ�8ɒ����R�]�ܖ���{�ɏ%��m�3�d��B�tC��w��㘨粴���RU3T�G_��N�p�Y���>��Z�dfrqd�@�\���*qk��I����A#bU��yֲ��ZV%mC�:E�㕞��K�$֪Bf�����bC��E�|ӡ34��+~|i�	8r��K�D�̋���K<��~�"��A�B�����qv���a��#5�S1��=��$ ��� �Ѯaz�S�n?D.����G�������$��?6N���m��?�6T=ڐ�6a}K� �ُ����jaQ���J��\�Z�U��O�o_��OB�G?�PAߢu͐ж�̻($�a�S��H��tlC�6\�/����(�s��cid��_,���� ֿ���bp5��o$b2BF/uѶ�2n@�M��c <��y�$]q��4,���f���:H�f�º���R����X}�&I}�mXF���!V���h1�a��2�M��?�F	�4C�"�)����Z��*��@M�#mVVg��d�RX�T�o�N�K�ٖ"�|�x;6ᐸ����'��K�N�y��F_Ք�d�mu�v)��k&���cA�[�Q����.4љ��`L�q&���N��U/��Ħƪ��(��$r&ebx�n������� @��I��{ s`s�?Nr�������
	�7Xw��>�o��������ۇ����.�34�@���;�o0k��a�:��AS��-˰� H�� i>�!�͎6t@p��%5�ӆ@�[Rq��eǰ��/"���ð$e�A@�	>{�j{����*���N�������^�����.�?'c;���`���nd|����W�1�����O�:K�{NC,!��\� �.Z
)�R����i�Σ�B�O��l�@L��na_FP�H���|&�r�$�)4N�gS�	�<��a�.U��� T�|&S�U�&�2�(�E���hg4��i)_��:ڏF�ɊZ}�磈�>f�����|1[?΄�����e��gЌ,%�����Sܱ��b�b��a�T���
�Z%/^�qB�tr�F�M����ϊ ��f�Z��͆��5U�N	>�Ԧ�n�����&`�x� �P�w.��<@�~N�	"�~P�c3����_��������k��w�C��?��w�����W�=c��-W��#�v��#�{N�3&K �ܴ ����a�	�"�^ ��e�����G�/�<�܍!��y+HS�,��z�K��E�%�v��%|�J���M��������%��ј/�ڪY������5C���a;��ܛ��MO�\g�߸���.\!��U�T^O���M��K�#�މ1CNO�T}`t�l&�2	�5�� ��6�/�L��d��%4 �}B+���Y���2�t�����"��)�q��O"-lA�S,���[�O?�=6��:}3���w,�N�&�Hk���]���h���j��ۀ'���މn������
��o=-D����T@���r��1�jG�a�,?��
���
�����״/���]���u��s�b�ۋ���-�{}�w�d)�P�\�����ǰ��o�*���#No�QUh��ug\���B��\j�m� >JB�ڄ��*js�2�C�w�Fߚ4��@7�@֠�?q+z�����u|��-������;��V���v�����]4G�8V��h�?�$��"&r��t�_�z^�Q��s�0�"�nj�B�cz���q��Soth����Oƽ�A�����6`]��IP�]�_���,Z;��x���݊�Ӗ�S[m4�������:Ҽ"�ۦ���A���w�ɺ������x|z�������cq����6�M��6��?ӯi�xKs�왋|����9���n�(�1� ���}�6�A����� !��C��2��{,��n����N��4�<0���)V�ɐe�p��֋�Ջ�͕�ԯgܞ��qā!ҁ��i��x���L���V�K�b�o�[_�>��zU}��C�M�A1�6]_������6�����8����
�U����`���Z�k�߳��%��N|��������hz�g�a񦯌���t� �m��)!���T%��WE�"��|A(�ă�4��-�}|u��C$���*�.��H.�<�49��#(#����忓R�?A"*�9�����rʋ��(t���q�uѾ������7��N�@�c�~�wp�����m|�o*h1e�z�����rF�)Z���82�J���n0�����	7n�"��񍘗"�h$`����O8�2f��*����
lL�{��q�������2���ہU���Ҫw��aГCk/��iՃ^��F���X�^�7��ޢ(X*g�M0�^�Q�zi,4�S���__l�_���-�յ��i��h���:������U�,���hZ���5hIj��$%���並,�&�ě�$��M�J��h&9)K@�椺��;�k���&!�Ƌ~����*��ڱ����.�66IW�%78~i|QY��;����)�p�v����w,W��&k�T���BQ��'8`Ë�P`��Z����B�9��'�?+��g5_-b��9p��@=̟0�T�q�"�iAڪ�+��4�Ǹ3�~܉���@�Ɵe���R����Q�t�-Ô�vԶ�hKu�������5W͔kg8}����彼T'36�6�~��0�����7��\��{�{P��]����R�6L��0�~�4f�/��x0�l�m��+�������� �[����,�7?����t)�:2l��e$ i+�=Pt"�ny��/�)������i��6t�;0�j��Gb�xqϽc#b�ԃ��z����d�H���6""����I�����.D�H�)����r���MM�(���q������42YTY٢����E>�W���їۙ�-��R-�ˤ�F�_�Y�qq���&�7��bs!
i#8%�ϥ�AS�l�B�R��vS���U�v�4��<�(��u����ݬ����_���:R��S�ĸ��J֙�̻ts��`A�@c��n�]��̤���>X:�ǅ�^�S��x�ܤ�,ll�Ϟ����]�?q�]��c����� ��W������w����hJ�Ͽ�Pf��²2��r�iF�Ea��12�1�8��)��)�����96�%{��l����?~������~���˟���/������~�>�7�7���~B��7MM�]I������c�i/{�����A���F"L����xo����ϛ�O�齽�zo��ч���3�B��{�)�����|��1����(���� >��ý�G�Mp^�g0g��������^��N[�������_��׿~����w�dt��{�jK���g�ރ������V����Xj���V�鿬6��1�����w�����_:���v��D���7'��:Q����Ɍ���z�? 5�H���O'o�?s0��e�mxw������Yz��Q`۠�=�?Gr;��x
�f�e�O���6`+�?���%�0�h&a\I$㜬4٤BI���l2�dc2�&d��q�Y�m6HEi*���ғkO
���g8jI������@CJ��ഒ?�E�n*Q�gs|KHR�lj�2[-Ē�w6����\*K�a>ŗ�-z�ꈳ��${�]W�vrި�Ou�{F��q/�f�$�ʎ`���<_�5T2��e��j�N�Q����!�y'j��<�:Rͩ��Ɇ�q�CZ�-'��n���C!C�OW�q�K��ón�e�p 3˃z�	b��*_��)r��o���/�M/�=��w�������Y�����������BE���h�����t�:��!�����W����6��T��2R��q��[��c�*�!�;�3�	Q�Y��	�v!}vV	�|%�*����t��nd�^�9�K����׼<Y̜�<5�%��a��֮/��(+��!
����:߿�h�)���v49�Spq� �a�-�<,f�゘:5��uܴ�4����=L�/3g�rV�ծ���+�*��C[:��=ּ��B��yT(���>��Ɨ�lG�(v��U!%{�ۅ2�^PYf9;�Nz�AC���G�2����M+��<����E�$
�d�Z���o\]�52�Ӹ#���hV���i�.��ج��aٺ6%��=��ʧ��>��G���X8;/�f�#�)���p��PHE�eL������5A���T����D�ղR-�0U���S�RH�̈́��_�E�Wa���ҩ�xV;�/`�R���湒ը��U��s4�����i�d���^����i���[��I	���/��F�Z�ח��2zg����⹡z!�/��خ�$[/�[���n��\U�sA9��3S��vc�^����Gl��E�7��<6KoOB�:���[����{w�{�;�m��>������V�)��$�?gv��-��"F䱇��������G��Ԓ������������S]�=�U�����l��P��������S��	J�SM�I2$c㔜P�d�!i�"�$	I�``��'(��$��!��&I7��$��"t?x
�?������y���u�k�ȴ/�ĉ�n݋�q��r%3yԒ�ʅQ*��_�c��O��fʧW)&y]yqt��,�yQ�z��C����X4���:z�qQ�(���$?�H�V\��Z٪�jAH\^��r�/�?{g֬&�m�{~Ź��H/\|�VEPP@�9E#(v`����6ݗD�d'o6�ʞOUr�&V�d0�Zs�eLT� ���4��OṢ����0?�?$Qݻ�`�Mx����G#�����_���/���*Z#u����?�O�?��`��~��i䲌�s����{�l���tQ��>��+�u��Ru�$�M��o��7���k�ǋ�\�ȋuC���.f���d��v����.�|C�������阕��c�ԪP�R�6�5ڬ�T��ZQ��g3�����*b�:��Pu?�aE�f�L��h%�|�u������HwO-MmU�U�%>u�����a� ;V����-v�Pȼӑf��:M՗����lV1'/8�"-�b�%�)ZIڊ;���6��*4����e␪��v�fki�R����C��{{��WP�g���{�f߶M�tY>��v��;.����3�cO�l"TU�/�K�]�v(sV���6���'��:E�\�@t+-W<ݜ^�i���_���O]ŊS��A�L��{	E�������ƞ(쮜��ф+�	�}����S���tn�/��M&��9���J�^i�҈���Hꏳ�����jQ�Q��������=�
�?F���������h��?� �����?����:���(w�o|5�y>�3I���Y�(��@�K�?�?>����y�uo����O�3�Z�w$��)cu�UY��6�]��t�5�}b�`��A�/�1� n����R�r,}ݓ�ƼWM.�Ւ�HD�}ݎ� ���#��W3��NA��3���u��G;ͯG;Q��)t��.��^���^�˳�ř���4��N�x�y�T��k�TkULJ�>.0�:q��/�TFd�LՕ{�Lk#Q���%�M��b��z�E���lr^��GyR�2"��Y��	�֤4V�K�}~��[����N�R
� �h|:�5������d��ks�������}�����q��ߏ�&��g�O��R���O���Ox�x��$a�����?����:��������F�?����G�a̫��������~�����P��ØW��K�u���a��`��`�������E=��y5����k����/>��0�͢	��Y�ˁ������/����/���=�������`̫�����_���Q����o��߷������?^����x����pSܟxN��w�?�����4���3��uP���/�Sm��X��?�?v����A�C-`��/�?���+�����������������<�H�"!)�O�N����b�1)���%"�t'��$Ri4瓔C&����V�z�n���O=�?��P_������&��j�y�O�L�~��$�d��m;#';y07r8۝g"ڜ9+/yz�I�u��|���R<n�d���f��Rm����f#���8�R�p}��-�+Ѱ@��Dg�	l��2�2���q�u�ͼQ:������<|(�_x�h�󟦘G�ׁ�`~�C0f������F�?�����O-4G��7u����r��Y��	����	���������0��}����g����[�����"����r����p�_-�4���m����/�FY��~���|��Y�?�V�����t�E�sr�׹l�����hP�[�%rt]��ݶ;uV;]'f��ѷ���I0r�!=�3)$íώ�T�tf[�Y�}ڛ0�C������c��⯻�|�����5�:������jlZ��aT��m>��Z"��C��eRw7�^���'L-�ܺ�V��1��ͣ��5��U4����l`�� 
3���w���ga�����h����|��?����?��C��oY�=?�|?n���������������������h��s�(0IG�t��a'#a>�"�9���9�L��q�!�NG�y̑켓vX����=�������?��!�Wg�G�V�h'��%�s;�J?s{�BY��\�9���O��l]���*�<-��I�'��䬷
1缥P['Xh�SN�i`1���CьL�ߍ�7.Rfا����2����&<�!��������&<�������h��C���}�?��@���@��@������̀���_#��?���~,�1M����?�?��~�������{�l���tQ��>��C��o�H3�*�տ��hn���B李4��i���?�vg��9y��i9O[-Q�L�J�Vܱ�跡��U���T�-�T�0/��5k46�éP�^&Us�=��"H��a���jcOvWN�E�h�ξQROJx�|:��g�&���J�q_%U�4Xi�Z�e$��Y�o������`s�������F�?�`�!��M��������������o���w�Q�3����ߞ&���?����So��?au���q�g���@�����<�?�?�P�����4����W����a�������X�n�g�5�1KW���=$Ɇ/[� Ʋ���f��ᢦ���_���p�+�K�a�=��/u�+o�� �Fz�hNVe���4��A�Wus�.����4�R���>
�D��J*bhF��0ǲQ�NY�����^˽�J�mY��|
Iz)���Q��.���zH�4�T�^r@GDɭ�r�^�n%��1Y�o}�L�0q���T�'��e�dF93��\�CyVA�r��v:�v�])Β`�-�?M������!M'a�p|D�a�uDzr̜�R�O�x�RI'����_"�Di��|Ȳ�<��ތ&��g�O��W2���@��ZE�I�Ed��6�|,�4�]�����V�u�O�Oc�����+��©��{e�R�70{}bA��!H�h.�{�M�qfO]q��N����q����GJ�{��lY���^K��Գ�?��������h�l*u���Y��yX���&�?��������;��O�C �����c�8�������?�?n���?����ǉ�
�<����KX����/�s���4
٘�IS1$#>�bı|��T"��������0��Sr��u�ף�S�V[K�n��ݫ������pW
�(^_�� W��?���k;���h?h�������������@�s=��T�M4�Vm���þU��n��d�vz�ĸ9���?����o���ki�������?����&<������=�?�$�_���/	!0*R#u����2��W�����l�{���Uθ�H��a��������χ���y���O�d�#m%Ye��������٢���p����Lt=VV���u�Ҳ���A����t�o���l8��r��l�|�����%}��CYR�1��S:n��Tw���4��g.\������?#�4v�^;�Nn�崓L:���5�3^��,�b\FI�=���c�
�}�3�ub�7�k��x�BXn�����N����u��F�p�60�p�f���������h��?� �����?�8��~�������o��`P}K:��m�,�a*��K��?�����y�uo�������&���J�gq�Ҩv���h�'7R&ͺI�Zl�����on���o�v;�燅c�-��Ka����}ح�<ȥ�s��Uƃ�S��sƃ��ܗ��̯�P��)t��.��^���zF︿y{�<NW�b�R�mv.T[/��n�:�;-�P�_~\`(u���_���+�l����ɰ%�9U�]�"�˅a���)��U~���S��+9n������l�g�]�|�/�r��L[6����D{��F�p�60�p�f��������`�!��M����
�@�#�?B�#�?�=��1�����Zx����P��o,u�����,��S����qQ��ØWS��ǭ�4�$�	�k�v��1�FQ������?�������^��������1����}�M����G��ƿY4��?��z��@��A���=��I���PO�c^M�����������?`������\` 'M����������)���S�K���V���՛�H�hY���!�d��}�/n����zUY�Z}pۓ���r41�R�O��hQ3߻N��Wy��5����8\v�e1�i$�"r0��ut��h�]�r�x�����z�;�U����i�h���MV��Yk��l9�r�5���{�=w�*#}��wȡ$��ٷ��P�lԶ�m����>�-;�ڦ��K�g����/����>A'��֮�E�O�B������
و���l�k��oBay���(�v���iu���s�:K������_w�6�s��������)���s��f�P���>`��`��`��Z�?���D�?X������h��5�N����U˴Y0��xo�۵C[�����-�����iǎ�]ՓN�-
��%Q<U�����!�cA�ɖ�wV\Sb�������kC7U��i�����v=zX����o������E
?�0���y�3�~�݃ �ɓ��MXu�����IQ����wo�e��"DDPE��`V�PT�_���zK߮�����ʳ�04��:yN>���g Z�;_����
�$�qa��9��W�?��tH0�1;Ei!���}5�A�����������P�޴��x�:������h������	�A����_�����_�.�NM�?�������_kA���H��~�K�D� �C�o���G�?��R���	�l�ci��!�07:�:&X���(q<�(��Y��9��C�'(��x�X���O����h��~�����Z��7��	p���d����@&?��	
V�ڠifK0�&��o/����WS�w���]�>�v���mf��P��,`� Xq���WvSk8�+|����(ְ"`6WW�<��!W]�_�~���\K���nt��x���<���������uwQM�-C�'����:�����F����C+��z��`�����aoP���?��C���Z �`�����?0����o��m��
����kAk��� �����O���3���|��7�k�����f��䎢�	�N�����?���?��Q֝L�e�w��,>�C��kC\Ϋ	/S���nL�(��̂u�!�f��2�$_:��$�]i��P�����>!Wyi�`���(ɽ\�^->���w7W���%��y����[kr t�T���ׅ.j@����2�i��tq(
�W�ΞpT�j��n�?����m��=��D�ʞ�K6?<��-��	3��:��vd�܀����f��괿���tJ�{�*��� �Ц#j�M� 8���Z=���0��14��`0|À��k�V�?���BK�����������a���a��@��'��m�����_[����a�Gch��a�GÀ���i���͡-��c3,%I��d0|HN2Q�PF�)�<�%�RN�i�F!	�?~m����~g���:n�u��.�#�M68p����� �"@8�0�w~��0��/]S&�=1�QI�ը��Z�1BS#z��4S�R��V��K':w�c$q���^�z��}t]T�y���,�0���������?F����C+��4���?��������p�������?0�����h��m��
�����5��x \��h�����~�.����-��(���T'&�;N����iOKg46��s`W�|���c�o��o��mr?$�
;��z�sp6?�>w~~|{N�'D��������-���/K��B��S��s�Z�t˫��鵞\��Rb���peau�{>,�v������B�~�i��P��W�2>x�׻�J���"��
��0G��Y:v�]�6��JZUS���G����;L��d*"�	%�;A[��¼����e��e�v�e>�?�/���Ld,�#s]��=k?Bn�\ 7g�f�U��M��Q*�w�w\�A�����& � TZ�I��]rA4+u�͜8n����,G���˱7��n8?�z���=ܬ6����U%ɪ@e5孶�v݃g*�:�O��aMYvq�^���͗|�U�v��e�
=���2ְʻ��N���k���Ƣǿ���4Z��`�GchX��������������Z����7�6�X�o�������u���%�ovq�{?��?>��1��������>���N��_�����W�?MP��ׁ6���[�����P��?��-F��#�O����[�'��������w��
���;�s����U�*�����n�ߕ����E�]��2+9{.�����WF>]�W��ے?�+5��%��G��~��?����ޯT�p��9z�����P��-���3X��ܬ8p��S�g�|+�Gr�#&-^$Z��X����-��>��7:ya>!w�xE��9�"/����XT�o��3�g�~;�#�*�|�����'�p���'�*����1���#W�Ppœ�7)Y�ْ̌˅�*�&3�ȝϕ�} �S6�u�[r-�&����I6 �e�30�ٙ�}�e�3��Ⱦ���c{K'�NC����r�n�\ ����*U�5�ٯ{����v�r�Թ4z�%.i'ۃ���g��A�{�����ZP��qB��FL̳i��4��TJ�A̧D��D2L�sNqQBs<��	�]����Q���l��j����чڸD��~x�t�"[�����e�'[ϭ��Gw�������_~E�����E�������?5�O��� �ï����~���p��ׁV��U���?������x�C� ����O`����u�Q���?4�������Q�������p��A�x��1O�Ǥ8��L�42��7]s4�3ϧN2\�1��D��h�����&���:�;�?�ģ۳�t��<�R��N��G�#�`��:�/ҞR���v^�?Nt{鲿��;^�!�,��¨�#$/(%S��^8W�{�U��:��u:�(����3B�[�.0i��a����Ϣ�?<��94:���G����C+���;���Մ���s>l�u���?���W��������ޭ�#~��N����Mx"sĞ���_�������J������ǟ�s@��9h�-�B`�'�<����B�K�d$2� L�j��7�AO#�v��re�G���#z�_�k_�hs��zk� r/�qݍ���{,K�S����m���oY��7Q+s��P��=�=�_���x����n��<u�ݾi��.Y��$�������.��*/rlr.*vO�d����2�؟HyogV���q�9`F:�)����j��`�I��֐R�ɝ�.��)n����Z��`�cchT�����_[���������%���U� P������/����_n������KF*����Yp��Ĥ3���~���*�����c����jr�������=��W'���M'�S��y��(�øTN1����@P����p{82F��UF��T�EE��x&�=˔�nh�6A�.��������=�=����L�Ï"0J�59;��J�`�$�]�.�Ֆ�>K�6`�^a��#��An_���)).�w�@�5��Wv�/�id)Bi��v�f_|��{���?kA�����8�������O>����?ԂV�?t�����.���� �a�#�������We�~^��,�A�_ڠ��j���P��?l�h/ �C�o���G��0������ͣe���?��q�������?`��߻��ڠ��j�����a�G{����m������&������������<����p����u��A��������?Ԃ:����^@����_���5�:������.����y��$��u�#�o���M��${}g�8�Q���F`�u_������L_����g����7c��1ȃAUo�U���uG��|L�����o��B��fY���_���d|���}�.Kt�$�e���hE�#��`>_�I7�D�����\:�F^d_����������~�&�m8�&�xпo��_@�x�T�=�����u�dCߟ��j��$Ƕ�QظƎ��3'����]��9(}jl����+��9�Y��&Q�y���"����ǲ�SȬ�c���80z�q@p�t[$����f�\ř�GL�IRoI �ԍ�%���9� ���z��{JK����ig�˺�-���I�oV��n۪��1e�YM��<^��j>���b��ƽ�\��%9��ԝǌ+�]�'�,��<YP�Z'4��L�4Z�P�Yh��{�����ZP��{+���ʿ��c�`�o-�@�	Q~���Y�U�;ٝ���o�U5�*��?�/�hq�i�����ZTF.WO�����\~��ߔr	�f97$����8�x�`�c�t%,��#�!J��O�王�ē�%��u�M?�.f��͕�k[S�cE�I���\ֻ��eBrv>Ʌ��|ͼRu��d���e>�E����]q,�-r�#�+<=E{7+���_$��Q�Ӆ �~4���]��)���d[��T؋�h�a]c���<w&���d����?J�W}3��XAvK43ʾ��m� �H	O��nT�C��=I���y�Z��`�Oc�y��_([�V�?�����ւ��_x��ci?��E�t���?5R&˛�C>���z�8r��
����~*E��5/� ��)�C�.ýȇ~�6�\g��C�9�t�lϮU���aIvg��u�<1�]7��龮y9�n�#�\�bH{��5���{7�c_dr���A��3y��S ��[H��p:���ˎep�s �mV�����ZB����7�g���%��LE��﫡��C��j���������-�����ZaSD����2�W̶��F��������k�L��n�O�����we1���ݎ{L{�-���d��]�^�e�hx�$u�ҕ)��HI�DJ�$À��"E�$mP �m�HZ�h� yZ�@Ӥ(
��@ߋ��Rڙ������ή�z�[`G"?�������?��p$ ����A]��r9Ɏ�AA�ڼ�k�<;�]���s���;��TC��ѐ6"�Z	k�ŗe�j�h�_�4
�棠N#@MU��tQ�k6rB�'�N
ꏤ"�h��E�crK�7���B;���UFUuf"FCyŁ%F�X1T$�-�T�-�2s8����.w�*kv�^+�0|?��1��O��������6��M\���6�I�����%�I�_R����o��I�w���/��n�9��}D�߫�]%TN��y�ε[9���4Z��$�6R�"k�E�+d�̄]t4ě\=K5k^w�3���y^m�0������b�\�}>_�6j���eR�Ӳׯ�������}� �9�9�$r�céY,{�Ϩ!EA�$_�<+�]Y�������1%�	�j�I#�@lף�UE�b�;ӭ!K۟~'�'���_0�#�������p��M�e��a��R_��g2��z��?}.�C�h��ׁ���sm��%H���7��Q��7��ׂM���9�~`&�`�H���7������H������E�e��F���$�X���
�B2�hF�4�t�23������n↉�3��>�����6��D��"�����5�X���>�m�����2ʼ1y8Җ�AQ�yJ�/�A��!�n����u�eEH�r���C��u%z9|I�ZP��lh�<M͖�D��D`Q�t�xZ��PZ��Vj�2���KiN�?�U�ykn��A�s�r/�u�6}���`�Q?����l��'=���`���os�
�����2�s-����m���׫���R��$�?I�OR����$�_�o��_�|;���O����� ��%�ؼ�?�.!ֈ�����4��ׁ����2�׫����n{�{�ba�B���=����k��{���飚V&Ǵ�Ȱ�c�<�po~c���2=>��9�C�lnȔ8�^cI]�X����pR�*��R�I�)��	f��ֈQi��H����\�FR��Q��2�ӹ�|�V�������,k��q+��ƍvi�̆�孽2����hL��0���B��k��|/�VQu���X!������\�t9+��l�h��6�J�Q��I����HWm�9�T4)�:�b�Th�&ke��ak\��"G�Gf	�[R/�Pdo�"�OB|���K��6��%=��I��d�[�������s-ش�O���b+��$��1$��$��������C�Ӹf�vm��b�����6��H��?��<�����6�L#�i��kfjd�Ch���N�(���dP�DI��tK� jf��t��`=����H����I����������U@eXH5L���6pw|[�P�� ���tUUK�R���T��H)l�Yt8F�6�1FQj��qm\��F���Ѵ�r����EJ�N��R1͜W$�3z�P.� o��D���������n����L3X�:W9�%�?
g�?�D���ׂ<m`�{prG�>�Cǈ�U)˵xI�����]o��}�Y��wVdO,�5�x}`zcٌ���٥�~p���xvш�;�y,rS">�s��V�xl��C�}�d�ѵ���uzK��w�dG����u�,L�^����D����]�i7�2ѲIܡw�6q�.q��M��-e/���؇p��)��aȏC�4�Q����c�F?��G?��A�	�3$N�e�V��;
�YZ<	�9Z�9Ѧ�ܤ"wr=�2���EM��7�x���\��R�&{��8��S���'�IR]4����:��Uy��Aꕞ0��Z�)�鈳W�E��[�Q�h�a/��r`CI�w�)�yZTs�g�ttzbp�L���C/ޏ˰bT�i�w�i��F�)����D;�bZhR�T���BSB��U����1�!Et$�E���>�&-1{��LJ:���9$-�,�k9��>�a�-r�r詒X�д���/2377�ԥ���M���NC�C�Dǡw��nZO%x<؎�������k����Igӧ����ы����_N��*#�����C����.p�]��{�t ��m��}zp���~`�wl�3C'�����%�Ã������?� ���� 8���+�����k��y�߿�����������?��]�w[�wX�_U�*�c�_�y���{����׿�w�=xqo�]��㭯�$ֱtS't��D&M���-��4�!F��P
�dZ'��t:D��LEa� ;���*�ɷ���?�������������|�/�����(�?)�?*�o����^�ǡ�d�?���m���sro�o���<�a�����
<������?{��W���s������ L��8���e����ƀ�z-��8�{�� ����W=�/hqJ���.:��U����e�jYt��e"`Iq܄� ��M��b�+�Ñ N>W`uE0�Z~��$;�y"h�r����� lv�.O�Q�B�S%�GCڈ�j%��_�Y~�I#WS��	f����0Y�f]Zdli���P�NP0
�-9�2ۻ�C[t�u�أ�棠N#@MU��tQ�k6rB�'�N
ꏤ"�h�bʮi��-{���b[h�ʨ���B�h(�8Т�H+��Ĺ%�ʲE�Bfg�6��.\e�N�kE����a���#F�2������>��r�#�.�]�)�K�C��9�*y�f ��hX�f�j�3f3���
>4�HS��`j=���׋�rM�X�+gsJ��+����������D��]�Db�
7����f:�]��'d��]���SPn��2�&�!P�'X{���l�\�F��Ī��P��nLz3_LuKT�ܩ�o��H�.G��Xm<h4��X�V���V�_j�oB�7e���My|�4>pS�)�ܔ�nJ�7e�����U���,����r�F�����s�4_x �7g�|ூ���4��>����S{/�/���'[ ��'��c�ϟ�`|�d�e�p� ��W?�[Ǉ���W�Х�ӗ���{�y�x��.����V^�K�3�{�
%�k*є��ϐ%?_ļ�x���ж9��U��sBW����R��݌�rdu^F�t�ݮw�A-=VL5*C��5)�hW����b�)�|	W�Z˞ ��R��<[o��P^���䕺Z#;)�j�Q`a5�|)��.�Ѝ�ҶfVnf�,�9�b�=����G~E�"��h���ꭱc҅�if�Q/P�jA���.ڦK�=��p��5r2�ևY.���^��Q�Y"�� ���]�0$�VV�t�ʔp��m��^�8�5�然�����B�BWm���1��B�ie����v;�&�ִ, �ȴ81;��S��S��T�/���FÜ:jf�!�YUsG^�����J=�Υ��%#�OҼ�ʨQ����rs�7���l��7�Ld��q������D���Qs<b9j��!.���T�W̦Y��$_5_.W��\�����Ǚ^i:�$ۅ�fb��X�!L,z��݃�Wخ�yf���x���w�9�*���3���o9�ቍ���r�0�OS������K���o��荻V�o����7>��{�����(�>J��.�K�{)_�/���<�/ɹ���(����n����4�&��8� =������!�(y��L&k��T����+m�;��P���9�Ӎ�_�HQo��A�Gm?R{)鳺�M7[�՛�:F���Mغ֛LG�,��)[P!���9���9��H�"Y���6G����6'K�|6�{�Zӆs�~��;�R�x[��]� ���^]�ñ�
!��ZA��V��A�AmU	�mq<�A~�M���|���9�<G��xb�	[�y��U�2�*�&�ëg�u�
Nf=Mf=}2g=�/���c����4�w�e||�4�wz�c����'蕷9a4��#FS2�q�����c��/��1��NBe>4�[�s�����OD�m�wega���/� �>����}�j7/�dg`��1����gQ�p��.�k���3K"�h�i���s"s������x|9����̉�[���8ܺ�w��{���\�����wϦ��u ��|?y���>��7�����q0�Ǔ`u�v~�s'�p���І�ah����=�������4L���b\�\�੻��T\u����Ï��j坰{�c\2�=;��N�?ւ/}�8ԉ_l ��~v��}o�r�p�o���?o������;;�<#���x�s��&h��q���'Al��������w �(�w��7�uc�'^�,7�?��r�}��Jl���o|x��k��o�##��ܭܝĻ��վ�X����w5�mQ�Mj�"���uk5e��+�媡�JT�5��(����1Y��uk7J�q �N�\�+�_��.���ļ�����q�n!�w��3����{of���\�ӫ�P�q�m���D�z	A�\��� �Ee%�J��̵j&lU�r��0�J:�f�fB�#u�h�tک��T���\[	dL���GJݱ+U����7+���Z��{���vI����m�Z�o1��;�*ħ#�z��g��O���}�����}����8�M[/?��ȦR��&K�xy���ra��|����%>kwLV����?�k�|�7�z�c��N����3�o.d62)E�K�%���a�}�:�n�Z0MA��06˥>�z�}���� �R�
~�ڟ�G1��U���M�Ք�@�Od���5tۿ�g��u~c_��V^���>����a��'��C�W3Yz�<x��/�5蟶�|ib��#��WI�Rm��9�p�`��#�s`����l��ž㿚Mi4�(�n����,��b�W�d�� ���F��<�g$cX��}��_%���i��>��L��\�`[f��_�cYj���7L�8����{�����W\Z^�X���\(�o��^P-!ߔ|�W�	�T|�����T��(w!�}e��K]^Y]�q�ls�s��%��L� �E�˼wAw�F��o��o�mǃh��\f��������u�^��V���]-.�7���.���8X�H�~��i�vXewf�-Dj�մ 8,?��ZB9�~6>�?pO����
�߃��`}�Z
V�<\�=��j�J̑��-Ǖ�z�b]�!7�ۡ�A���Ğ|��;,x9:�����X�-���u=h$����ڕ�Ok���&h�7���-C�a�<5�f���☇��u;����㥰�����i[�
j>�H�]����[[A�.�Td�������a۸	�[�pF� �|��#=�Hz������p�[�6P�
�d[�ӈuj ��rw���hw�Z���]��xa��ED��s���Õ���t��R:�<���>ma�
M[�y�蟉�q���㷪�W{F��e�IC����Z��ђ�WP]��^��r��撼�<�`%Խl�-��e��j2/L�iD��|�w6��&�u�.�,�����pDg39�u�A��(L����ZT-|lAk�l'Ǖa�@�qQ&� �f�I� Jӷr�N��aA�kr�+�x9������l[���<B��ៗ���K����Ϊi�����ҙ��j2��(����c<�|||b�����EN�ᐘ��.0#]���i���9�Ւ:+��i-�g���IV�jJM�(�+F��I,id����H�������ڣ�ߤ������������rO&~���NH_OH�����z�Ŀm��̓]��#]4S�#�|��E��V,��v򇣱/�F�l?i'"A���{Ș_)��9�����O�<��.�pL��n[����������x��㿦��ŷ�w������������t������?w�
���� �&���\�E ^�E8���7��M����L����L��ĨC�:��L����L����L����L����L����Ly�sP�����<�V�xL�U���*�R�������������������	�@ �@�ƿ��] � 