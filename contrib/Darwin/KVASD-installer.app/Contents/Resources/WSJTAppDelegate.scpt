FasdUAS 1.101.10   ��   ��    k             l     ��������  ��  ��        l     �� 	 
��   	 #   WSJTAppDelegate.applescript    
 �   :     W S J T A p p D e l e g a t e . a p p l e s c r i p t      l     ��  ��       KVASD-installer     �   "     K V A S D - i n s t a l l e r      l     ��������  ��  ��        l     ��  ��    V P    This script is a drag and drop target that expects a WSJT-X app bundle path.     �   �         T h i s   s c r i p t   i s   a   d r a g   a n d   d r o p   t a r g e t   t h a t   e x p e c t s   a   W S J T - X   a p p   b u n d l e   p a t h .      l     ��  ��    U O    It can also be opened with a file list or by dropping a suitable WSJT-X app     �   �         I t   c a n   a l s o   b e   o p e n e d   w i t h   a   f i l e   l i s t   o r   b y   d r o p p i n g   a   s u i t a b l e   W S J T - X   a p p      l     ��   ��    Q K    bundle onto it. Alternatively a target WSJT-X application bundle may be      � ! ! �         b u n d l e   o n t o   i t .   A l t e r n a t i v e l y   a   t a r g e t   W S J T - X   a p p l i c a t i o n   b u n d l e   m a y   b e   " # " l     �� $ %��   $ > 8    selected by clicking the "Choose target ..." button.    % � & & p         s e l e c t e d   b y   c l i c k i n g   t h e   " C h o o s e   t a r g e t   . . . "   b u t t o n . #  ' ( ' l     ��������  ��  ��   (  ) * ) l     �� + ,��   + U O    It fetches the KVASD EULA text and displays it in a dialog which the reader    , � - - �         I t   f e t c h e s   t h e   K V A S D   E U L A   t e x t   a n d   d i s p l a y s   i t   i n   a   d i a l o g   w h i c h   t h e   r e a d e r *  . / . l     �� 0 1��   0 U O    must at least scroll to the end before clicking the Agree button which then    1 � 2 2 �         m u s t   a t   l e a s t   s c r o l l   t o   t h e   e n d   b e f o r e   c l i c k i n g   t h e   A g r e e   b u t t o n   w h i c h   t h e n /  3 4 3 l     �� 5 6��   5 V P    downloads the appropriate KVASD executable. The MD5 hash checksum is checked    6 � 7 7 �         d o w n l o a d s   t h e   a p p r o p r i a t e   K V A S D   e x e c u t a b l e .   T h e   M D 5   h a s h   c h e c k s u m   i s   c h e c k e d 4  8 9 8 l     �� : ;��   : "     on the KVASD executable.    ; � < < 8         o n   t h e   K V A S D   e x e c u t a b l e . 9  = > = l     ��������  ��  ��   >  ? @ ? l     �� A B��   A T N    Once the EULA has been accepted the "Install" button is enabled to install    B � C C �         O n c e   t h e   E U L A   h a s   b e e n   a c c e p t e d   t h e   " I n s t a l l "   b u t t o n   i s   e n a b l e d   t o   i n s t a l l @  D E D l     �� F G��   F S M    the KVASD executable into the target WSJT-X application bundle(s) and the    G � H H �         t h e   K V A S D   e x e c u t a b l e   i n t o   t h e   t a r g e t   W S J T - X   a p p l i c a t i o n   b u n d l e ( s )   a n d   t h e E  I J I l     �� K L��   K R L    RPATHs are modified to reference the libgcc support libraries inside the    L � M M �         R P A T H s   a r e   m o d i f i e d   t o   r e f e r e n c e   t h e   l i b g c c   s u p p o r t   l i b r a r i e s   i n s i d e   t h e J  N O N l     �� P Q��   P $     WSJT-X application bundle.    Q � R R <         W S J T - X   a p p l i c a t i o n   b u n d l e . O  S T S l     ��������  ��  ��   T  U V U l     �� W X��   W 9 3  Created by Bill Somerville (G4WJS) on 12/11/2014.    X � Y Y f     C r e a t e d   b y   B i l l   S o m e r v i l l e   ( G 4 W J S )   o n   1 2 / 1 1 / 2 0 1 4 . V  Z [ Z l     ��������  ��  ��   [  \ ] \ l     �� ^ _��   ^ Y S  The author of this work hereby waives all claim of copyright (economic and moral)    _ � ` ` �     T h e   a u t h o r   o f   t h i s   w o r k   h e r e b y   w a i v e s   a l l   c l a i m   o f   c o p y r i g h t   ( e c o n o m i c   a n d   m o r a l ) ]  a b a l     �� c d��   c ^ X  in this work and immediately places it in the public domain; it may be used, distorted    d � e e �     i n   t h i s   w o r k   a n d   i m m e d i a t e l y   p l a c e s   i t   i n   t h e   p u b l i c   d o m a i n ;   i t   m a y   b e   u s e d ,   d i s t o r t e d b  f g f l     �� h i��   h c ]  or destroyed in any manner whatsoever without further attribution or notice to the creator.    i � j j �     o r   d e s t r o y e d   i n   a n y   m a n n e r   w h a t s o e v e r   w i t h o u t   f u r t h e r   a t t r i b u t i o n   o r   n o t i c e   t o   t h e   c r e a t o r . g  k l k l     ��������  ��  ��   l  m n m l     ��������  ��  ��   n  o p o l     �� q r��   q ( " curl wraps cURL to download files    r � s s D   c u r l   w r a p s   c U R L   t o   d o w n l o a d   f i l e s p  t u t h     �� v�� 0 curl   v k       w w  x y x i      z { z I      �� |���� 0 download   |  } ~ } o      ���� 0 url   ~   �  o      ���� 0 filename fileName �  ��� � o      ���� 0 destination  ��  ��   { k     3 � �  � � � r      � � � b      � � � o     ���� 0 destination   � o    ���� 0 filename fileName � o      ���� 0 file   �  � � � Q    . � � � � I  	 �� ���
�� .sysoexecTEXT���     TEXT � b   	  � � � b   	  � � � b   	  � � � b   	  � � � m   	 
 � � � � � j c u r l   - - f a i l   - - r e t r y   5   - - s i l e n t   - - s h o w - e r r o r   - - o u t p u t   � o   
 ���� 0 file   � m     � � � � �    � o    ���� 0 url   � o    ���� 0 filename fileName��   � R      �� ���
�� .ascrerr ****      � **** � o      ���� 0 errorstring errorString��   � R    .�� ���
�� .ascrerr ****      � **** � b     - � � � b     + � � � b     ) � � � b     ' � � � b     % � � � b     # � � � m     ! � � � � � < A n   e r r o r   o c c u r r e d   d o w n l o a d i n g : � o   ! "��
�� 
ret  � o   # $���� 0 url   � o   % &���� 0 filename fileName � o   ' (��
�� 
ret  � o   ) *��
�� 
ret  � o   + ,���� 0 errorstring errorString��   �  ��� � L   / 3 � � c   / 2 � � � o   / 0���� 0 file   � m   0 1��
�� 
psxf��   y  � � � l     ��������  ��  ��   �  ��� � i     � � � I      �� ����� 0 downloadmd5 downloadMD5 �  � � � o      ���� 0 url   �  ��� � o      ���� 0 filename fileName��  ��   � k     / � �  � � � r      � � � m      � � � � �  . m d 5 � o      ���� 0 md5ext md5Ext �  ��� � Q    / � � � � L     � � I   �� ���
�� .sysoexecTEXT���     TEXT � b     � � � b     � � � b     � � � b    
 � � � m     � � � � � > c u r l   - - f a i l   - - r e t r y   5   - - s i l e n t   � o    	���� 0 url   � o   
 ���� 0 filename fileName � l 
   ����� � o    ���� 0 md5ext md5Ext��  ��   � m     � � � � � �   |   a w k   ' { m a t c h ( $ 0 , " [ [ : x d i g i t : ] ] { 3 2 } " ) ;   p r i n t   s u b s t r ( $ 0 , R S T A R T , R L E N G T H ) } '��   � R      �� ���
�� .ascrerr ****      � **** � o      ���� 0 errorstring errorString��   � R    /�� ���
�� .ascrerr ****      � **** � b    . � � � b    , � � � b    * � � � b    ( � � � b    & � � � b    $ � � � b    " � � � m      � � � � � : A n   e r r o r   o c c u r r e d   d o w n l o a d i n g � o     !��
�� 
ret  � o   " #��
�� 
ret  � o   $ %���� 0 filename fileName � o   & '���� 0 md5ext md5Ext � o   ( )��
�� 
ret  � o   * +��
�� 
ret  � o   , -���� 0 errorstring errorString��  ��  ��   u  � � � l     ��������  ��  ��   �  � � � l     �� � ���   � A ; kvasd looks after fetching kvasd files from the web source    � � � � v   k v a s d   l o o k s   a f t e r   f e t c h i n g   k v a s d   f i l e s   f r o m   t h e   w e b   s o u r c e �  � � � h    �� ��� 	0 kvasd   � k       � �  � � � j     �� ��� 0 
serverpath 
serverPath � m      � � � � � n h t t p s : / / s v n . c o d e . s f . n e t / p / w s j t / w s j t / t r u n k / k v a s d - b i n a r y / �  � � � j    �� ��� 0 
targetname 
targetName � m     � � � � � 
 k v a s d �  � � � l     ��������  ��  ��   �  � � � i    	 � � � I      �������� 0 destination  ��  ��   � L      � � I    �� ��
�� .fndrgstl****    ��� ****  m      �  T M P D I R��   �  l     ��������  ��  ��    i   
  I      �������� 0 	fetcheula 	fetchEULA��  ��   L     		 n    

 I    ������ 0 download    o    
���� 0 
serverpath 
serverPath  b   
  o   
 ���� 0 
targetname 
targetName m     �  _ e u l a . t x t � n    I    �~�}�|�~ 0 destination  �}  �|    f    �  ��   o     �{�{ 0 curl    l     �z�y�x�z  �y  �x    i     I      �w�v�u�w 0 fetchbinary fetchBinary�v  �u   k     k   r     !"! b     #$# o     �t�t 0 
serverpath 
serverPath$ I   �s%�r
�s .sysoexecTEXT���     TEXT% b    &'& m    (( �)) 4 e c h o   ` u n a m e   - s ` - ` u n a m e   - m `' m    ** �++  /�r  " o      �q�q 0 url    ,-, r    !./. n   010 I    �p2�o�p 0 downloadmd5 downloadMD52 343 o    �n�n 0 url  4 5�m5 o    �l�l 0 
targetname 
targetName�m  �o  1 o    �k�k 0 curl  / o      �j�j 0 md5sum md5Sum- 676 r   " 8898 n  " 6:;: I   ' 6�i<�h�i 0 download  < =>= o   ' (�g�g 0 url  > ?@? o   ( -�f�f 0 
targetname 
targetName@ A�eA n  - 2BCB I   . 2�d�c�b�d 0 destination  �c  �b  C  f   - .�e  �h  ; o   " '�a�a 0 curl  9 o      �`�` 0 file  7 DED r   9 FFGF I  9 D�_H�^
�_ .sysoexecTEXT���     TEXTH b   9 @IJI b   9 >KLK m   9 :MM �NN  m d 5  L l  : =O�]�\O n   : =PQP 1   ; =�[
�[ 
psxpQ o   : ;�Z�Z 0 file  �]  �\  J m   > ?RR �SS     |   c u t   - d '   '   - f 4�^  G o      �Y�Y 0 md5calc md5CalcE T�XT Z   G kUV�W�VU >   G JWXW o   G H�U�U 0 md5calc md5CalcX o   H I�T�T 0 md5sum md5SumV R   M g�SYZ
�S .ascrerr ****      � ****Y b   Q f[\[ b   Q b]^] b   Q `_`_ b   Q ^aba b   Q \cdc b   Q Zefe b   Q Xghg b   Q Viji b   Q Tklk m   Q Rmm �nn J K V A S D   d o w n l o a d   c o r r u p t   M D 5   h a s h   c h e c kl o   R S�R
�R 
ret j l 
 T Uo�Q�Po o   T U�O
�O 
ret �Q  �P  h m   V Wpp �qq    e x p e c t e d   [f o   X Y�N�N 0 md5sum md5Sumd m   Z [rr �ss  ]b l 
 \ ]t�M�Lt o   \ ]�K
�K 
ret �M  �L  ` m   ^ _uu �vv        a c t u a l   [^ o   ` a�J�J 0 md5calc md5Calc\ l 	 b ew�I�Hw m   b exx �yy  ]�I  �H  Z �Gz�F
�G 
errnz m   O P�E�E��F  �W  �V  �X   {|{ l     �D�C�B�D  �C  �B  | }~} i    � I      �A�@�?�A 0 savelicense saveLicense�@  �?  � k     *�� ��� r     ��� l 	   ��>�=� I    �<�;�
�< .sysostflalis    ��� null�;  � �:��
�: 
prmp� l 	  ��9�8� m    �� ��� B S p e c i f y   f o l d e r   t o   s a v e   l i c e n s e   t o�9  �8  � �7��6
�7 
dflc� l   	��5�4� I   	�3��2
�3 .earsffdralis        afdr� m    �1
�1 afdrdocs�2  �5  �4  �6  �>  �=  � o      �0�0 0 dest  � ��/� O   *��� l 	  )��.�-� I   )�,��
�, .coreclon****      � ****� c    #��� l   !��+�*� b    !��� b    ��� n   ��� I    �)�(�'�) 0 destination  �(  �'  �  f    � o    �&�& 0 
targetname 
targetName� m     �� ���  _ e u l a . t x t�+  �*  � m   ! "�%
�% 
psxf� �$��#
�$ 
insh� o   $ %�"�" 0 dest  �#  �.  �-  � m    ���                                                                                  MACS  alis    l  	vbox-os-x                  Π�H+   ��
Finder.app                                                      ���\��        ����  	                CoreServices    Π�      �\�r     �� Hp Hn  3vbox-os-x:System: Library: CoreServices: Finder.app    
 F i n d e r . a p p   	 v b o x - o s - x  &System/Library/CoreServices/Finder.app  / ��  �/  ~ ��� l     �!� ��!  �   �  � ��� i    ��� I      ���� 0 printlicense printLicense�  �  � O    ��� l 	  ���� I   ���
� .aevtpdocnull���     obj � c    ��� l   ���� b    ��� b    ��� n   	��� I    	���� 0 destination  �  �  �  f    � o   	 �� 0 
targetname 
targetName� m    �� ���  _ e u l a . t x t�  �  � m    �
� 
psxf�  �  �  � m     ���                                                                                  MACS  alis    l  	vbox-os-x                  Π�H+   ��
Finder.app                                                      ���\��        ����  	                CoreServices    Π�      �\�r     �� Hp Hn  3vbox-os-x:System: Library: CoreServices: Finder.app    
 F i n d e r . a p p   	 v b o x - o s - x  &System/Library/CoreServices/Finder.app  / ��  � ��� l     ����  �  �  � ��� i    ��� I      ���
� 0 cleanup cleanUp�  �
  � O     \��� k    [�� ��� Z    1���	�� I   ���
� .coredoexbool        obj � c    ��� l   ���� b    ��� b    ��� n   	��� I    	���� 0 destination  �  �  �  f    � o   	 � �  0 
targetname 
targetName� m    �� ���  _ e u l a . t x t�  �  � m    ��
�� 
psxf�  � I   -�����
�� .coredeloobj        obj � c    )��� l   '������ b    '��� b    %��� n   ��� I    �������� 0 destination  ��  ��  �  f    � o    $���� 0 
targetname 
targetName� m   % &�� ���  _ e u l a . t x t��  ��  � m   ' (��
�� 
psxf��  �	  �  � ���� Z   2 [������� I  2 C�����
�� .coredoexbool        obj � c   2 ?��� l  2 =������ b   2 =��� n  2 7��� I   3 7�������� 0 destination  ��  ��  �  f   2 3� o   7 <���� 0 
targetname 
targetName��  ��  � m   = >��
�� 
psxf��  � I  F W�����
�� .coredeloobj        obj � c   F S��� l  F Q������ b   F Q��� n  F K��� I   G K�������� 0 destination  ��  ��  �  f   F G� o   K P���� 0 
targetname 
targetName��  ��  � m   Q R��
�� 
psxf��  ��  ��  ��  � m     ���                                                                                  MACS  alis    l  	vbox-os-x                  Π�H+   ��
Finder.app                                                      ���\��        ����  	                CoreServices    Π�      �\�r     �� Hp Hn  3vbox-os-x:System: Library: CoreServices: Finder.app    
 F i n d e r . a p p   	 v b o x - o s - x  &System/Library/CoreServices/Finder.app  / ��  �   � ��� l     ��������  ��  ��  � ��� h    ����� "0 wsjtappdelegate WSJTAppDelegate� k      �� ��� j     ���
�� 
pare� 4     ���
�� 
pcls� m    �� ���  N S O b j e c t� ��� l     ��������  ��  ��  � � � j   	 ���� 0 
mainwindow 
mainWindow m   	 
��
�� 
msng   j    ���� 0 eulatextview eulaTextView m    ��
�� 
msng  j    ���� 0 progressbar progressBar m    ��
�� 
msng 	 j    ��
�� 0 
savebutton 
saveButton
 m    ��
�� 
msng	  j    ���� 0 printbutton printButton m    ��
�� 
msng  j    ���� 0 agreecheckbox agreeCheckBox m    ��
�� 
msng  j    ���� (0 choosetargetbutton chooseTargetButton m    ��
�� 
msng  j     ���� 0 installbutton installButton m    ��
�� 
msng  l     ��������  ��  ��    j   ! $���� $0 bundlestoprocess bundlesToProcess J   ! #����    l     ��������  ��  ��    p   % %   ������ 60 defaultnotificationcentre defaultNotificationCentre��   !"! p   % %## ������ 0 licenceagreed licenceAgreed��  " $%$ l     ��������  ��  ��  % &'& i   % (()( I      ��*���� 	0 split  * +,+ o      ���� 0 thetext theText, -��- o      ���� 0 thedelimiters theDelimiters��  ��  ) k     .. /0/ r     121 n    343 1    ��
�� 
txdl4 1     ��
�� 
ascr2 o      ���� 0 olddelimiters oldDelimiters0 565 r    787 o    ���� 0 thedelimiters theDelimiters8 n     9:9 1    
��
�� 
txdl: 1    ��
�� 
ascr6 ;<; r    =>= l   ?����? n    @A@ 2   ��
�� 
citmA o    ���� 0 thetext theText��  ��  > o      ���� 0 	theresult 	theResult< BCB r    DED o    ���� 0 olddelimiters oldDelimitersE n     FGF 1    ��
�� 
txdlG 1    ��
�� 
ascrC H��H L    II o    ���� 0 	theresult 	theResult��  ' JKJ l     ��������  ��  ��  K LML l     ��NO��  N   do the install   O �PP    d o   t h e   i n s t a l lM QRQ i   ) ,STS I      �������� 0 process  ��  ��  T X    �U��VU Q   �WXYW k   }ZZ [\[ r    !]^] n   _`_ I    ��a���� "0 bundlewithpath_ bundleWithPath_a b��b o    ���� 0 
bundlepath 
bundlePath��  ��  ` n   cdc o    ���� 0 nsbundle NSBundled m    ��
�� misccura^ o      ���� 0 wsjtxbundle wsjtxBundle\ efe Z   " Hgh����g G   " 3iji =   " %klk o   " #���� 0 wsjtxbundle wsjtxBundlel m   # $��
�� 
msngj >   ( 1mnm c   ( /opo n  ( -qrq I   ) -�������� $0 bundleidentifier bundleIdentifier��  ��  r o   ( )���� 0 wsjtxbundle wsjtxBundlep m   - .��
�� 
ctxtn m   / 0ss �tt  o r g . k 1 j t . w s j t xh R   6 D��uv
�� .ascrerr ****      � ****u c   : Cwxw b   : Ayzy b   : ?{|{ b   : =}~} m   : ; ��� \ N o t   a n   a p p r o p r i a t e   W S J T - X   a p p l i c a t i o n   b u n d l e :  ~ o   ; <��
�� 
ret | l 
 = >������ o   = >��
�� 
ret ��  ��  z o   ? @���� 0 
bundlepath 
bundlePathx m   A B��
�� 
ctxtv �����
�� 
errn� m   8 9�������  ��  ��  f ��� r   I R��� c   I P��� n  I N��� I   J N������� 0 
bundlepath 
bundlePath��  �  � o   I J�~�~ 0 wsjtxbundle wsjtxBundle� m   N O�}
�} 
ctxt� o      �|�| 0 installroot installRoot� ��� I  S u�{��
�{ .sysodlogaskr        TEXT� b   S \��� b   S Z��� b   S X��� m   S V�� ��� H I n s t a l l   K V A S D   i n t o   A p l i c a t i o n   B u n d l e� o   V W�z
�z 
ret � l 
 X Y��y�x� o   X Y�w
�w 
ret �y  �x  � l 
 Z [��v�u� o   Z [�t�t 0 installroot installRoot�v  �u  � �s��
�s 
btns� J   _ g�� ��� m   _ b�� ���  O k� ��r� m   b e�� ���  S k i p�r  � �q��p
�q 
dflt� J   j o�� ��o� m   j m�� ���  O k�o  �p  � ��n� Z   v}���m�l� =   v ���� n   v }��� 1   y }�k
�k 
bhit� 1   v y�j
�j 
rslt� m   } ��� ���  O k� Q   �y���� k   �[�� ��� r   � ���� b   � ���� b   � ���� o   � ��i�i 0 installroot installRoot� m   � ��� ���   / C o n t e n t s / M a c O S /� n  � ���� o   � ��h�h 0 
targetname 
targetName� o   � ��g�g 	0 kvasd  � o      �f�f 
0 target  � ��� I  � ��e��d
�e .sysoexecTEXT���     TEXT� b   � ���� b   � ���� b   � ���� b   � ���� m   � ��� ���  c p  � n  � ���� I   � ��c�b�a�c 0 destination  �b  �a  � o   � ��`�` 	0 kvasd  � n  � ���� o   � ��_�_ 0 
targetname 
targetName� o   � ��^�^ 	0 kvasd  � 1   � ��]
�] 
spac� o   � ��\�\ 
0 target  �d  � ��� X   �)��[�� Z   �$���Z�Y� F   � ���� E   � ���� o   � ��X�X 0 theline theLine� m   � ��� ���  . d y l i b� H   � ��� E   � ���� o   � ��W�W 0 theline theLine� m   � ��� ���  l i b S y s t e m� k   � �� ��� r   � ���� n   � ���� 4 � ��V�
�V 
cobj� m   � ��U�U � I   � ��T��S�T 	0 split  � ��� o   � ��R�R 0 theline theLine� ��Q� J   � ��� ��� 1   � ��P
�P 
tab � ��O� 1   � ��N
�N 
spac�O  �Q  �S  � o      �M�M 0 thedylib theDylib� ��L� I  � �K��J
�K .sysoexecTEXT���     TEXT� b   ���� b   ���� b   ���� b   ���� b   ���� m   ��� �   4 i n s t a l l _ n a m e _ t o o l   - c h a n g e  � o  �I�I 0 thedylib theDylib� m   � $   @ e x e c u t a b l e _ p a t h /� n   4 �H
�H 
cobj m  �G�G�� I  �F�E�F 	0 split    o  	�D�D 0 thedylib theDylib 	�C	 J  	

 �B m  	 �  /�B  �C  �E  � 1  �A
�A 
spac� o  �@�@ 
0 target  �J  �L  �Z  �Y  �[ 0 theline theLine� n   � � 2  � ��?
�? 
cpar l  � ��>�= I  � ��<�;
�< .sysoexecTEXT���     TEXT b   � � m   � � �  o t o o l   - L   o   � ��:�: 
0 target  �;  �>  �=  �  I *7�9�8
�9 .ascrcmnt****      � **** I *3�7�6
�7 .sysoexecTEXT���     TEXT b  */ m  *- �  c h m o d   + x   o  -.�5�5 
0 target  �6  �8   �4 I 8[�3 
�3 .sysodisAaleR        TEXT b  8A!"! b  8?#$# b  8=%&% m  8;'' �(( P K V A S D   i n s t a l l e d   i n t o   a p p l i c a t i o n   b u n d l e :& o  ;<�2
�2 
ret $ o  =>�1
�1 
ret " l 
?@)�0�/) o  ?@�.�. 0 installroot installRoot�0  �/    �-*+
�- 
btns* J  DI,, -�,- m  DG.. �//  O k�,  + �+01
�+ 
dflt0 l 	LO2�*�)2 m  LO33 �44  O k�*  �)  1 �(5�'
�( 
givu5 m  RU�&�& �'  �4  � R      �%6�$
�% .ascrerr ****      � ****6 o      �#�# 0 errorstring errorString�$  � R  cy�"7�!
�" .ascrerr ****      � ****7 b  ex898 b  ev:;: b  er<=< b  ep>?> b  en@A@ b  elBCB b  ejDED m  ehFF �GG Z F a i l e d   t o   m o v e   K V A S D   i n t o   a p p l i c a t i o n   b u n d l e :E o  hi� 
�  
ret C o  jk�
� 
ret A l 
lmH��H o  lm�� 0 installroot installRoot�  �  ? o  no�
� 
ret = o  pq�
� 
ret ; m  ruII �JJ  E r r o r :  9 o  vw�� 0 errorstring errorString�!  �m  �l  �n  X R      �K�
� .ascrerr ****      � ****K o      �� 0 errorstring errorString�  Y I ���LM
� .sysodisAaleR        TEXTL o  ���� 0 errorstring errorStringM �NO
� 
as AN m  ���
� EAlTwarNO �PQ
� 
btnsP J  ��RR S�S m  ��TT �UU  O k�  Q �V�
� 
dfltV m  ��WW �XX  O k�  �� 0 
bundlepath 
bundlePathV o    �� $0 bundlestoprocess bundlesToProcessR YZY l     ���
�  �  �
  Z [\[ l     �	���	  �  �  \ ]^] l     �_`�  _ %  NSApplicationDelegate Protocol   ` �aa >   N S A p p l i c a t i o n D e l e g a t e   P r o t o c o l^ bcb l     ����  �  �  c ded i   - 0fgf I      �h�� B0 applicationwillfinishlaunching_ applicationWillFinishLaunching_h i� i o      ���� 0 anotification aNotification�   �  g Q     pjklj k    bmm non l   ��pq��  p L F            mainWindow's registerForDraggedTypes_({"public.file-url"})   q �rr �                         m a i n W i n d o w ' s   r e g i s t e r F o r D r a g g e d T y p e s _ ( { " p u b l i c . f i l e - u r l " } )o sts l   ��������  ��  ��  t uvu r    wxw n   
yzy I    
�������� 0 defaultcenter defaultCenter��  ��  z n   {|{ o    ���� ,0 nsnotificationcenter NSNotificationCenter| m    ��
�� misccurax o      ���� 60 defaultnotificationcentre defaultNotificationCentrev }~} r    � m    ��
�� boovfals� o      ���� 0 licenceagreed licenceAgreed~ ��� n   ��� I    ������� 0 seteditable_ setEditable_� ���� m    ��
�� boovfals��  ��  � o    ���� 0 eulatextview eulaTextView� ��� l   ��������  ��  ��  � ��� h    #����� 0 downloadeula downloadEula� n    ��� I    ������� 0 
setstring_ 
setString_� ���� I   �����
�� .rdwrread****        ****� n   ��� I   
 �������� 0 	fetcheula 	fetchEULA��  ��  � o    
���� 	0 kvasd  ��  ��  ��  � o     ���� 0 eulatextview eulaTextView� ��� n  $ *��� I   % *������� 0 dowithretry doWithRetry� ���� o   % &���� 0 downloadeula downloadEula��  ��  �  f   $ %� ��� n  + 5��� I   0 5������� 0 setenabled_ setEnabled_� ���� m   0 1��
�� boovtrue��  ��  � o   + 0���� 0 
savebutton 
saveButton� ��� n  6 @��� I   ; @������� 0 setenabled_ setEnabled_� ���� m   ; <��
�� boovtrue��  ��  � o   6 ;���� 0 printbutton printButton� ��� l  A A��������  ��  ��  � ��� l  A A������  � < 6 add observers for view port changes on EULA text view   � ��� l   a d d   o b s e r v e r s   f o r   v i e w   p o r t   c h a n g e s   o n   E U L A   t e x t   v i e w� ��� r   A F��� n  A D��� o   B D���� F0 !nsviewboundsdidchangenotification !NSViewBoundsDidChangeNotification� m   A B��
�� misccura� o      ���� (0 boundschangenotice boundsChangeNotice� ��� r   G L��� n  G J��� o   H J���� D0  nsviewframedidchangenotification  NSViewFrameDidChangeNotification� m   G H��
�� misccura� o      ���� &0 framechangenotice frameChangeNotice� ��� n  M V��� I   N V������� F0 !addobserver_selector_name_object_ !addObserver_selector_name_object_� ���  f   N O� ��� m   O P�� ���  v i e w C h a n g e d :� ��� o   P Q���� (0 boundschangenotice boundsChangeNotice� ���� m   Q R��
�� 
msng��  ��  � o   M N���� 60 defaultnotificationcentre defaultNotificationCentre� ���� n  W b��� I   X b������� F0 !addobserver_selector_name_object_ !addObserver_selector_name_object_� ���  f   X Y� ��� m   Y \�� ���  v i e w C h a n g e d :� ��� o   \ ]���� &0 framechangenotice frameChangeNotice� ���� m   ] ^��
�� 
msng��  ��  � o   W X���� 60 defaultnotificationcentre defaultNotificationCentre��  k R      �����
�� .ascrerr ****      � ****� o      ���� 0 errorstring errorString��  l I   j p������� 	0 abort  � ���� o   k l���� 0 errorstring errorString��  ��  e ��� l     ��������  ��  ��  � ��� i   1 4��� I      ������� d0 0applicationshouldterminateafterlastwindowclosed_ 0applicationShouldTerminateAfterLastWindowClosed_� ���� o      ���� 
0 sender  ��  ��  � L     �� m     ��
�� boovtrue� ��� l     ��������  ��  ��  � ��� i   5 8��� I      ������� 60 applicationwillterminate_ applicationWillTerminate_� ���� o      ���� 
0 sender  ��  ��  � k     �� ��� n    ��� I    ������� "0 removeobserver_ removeObserver_� ����  f    ��  ��  � o     ���� 60 defaultnotificationcentre defaultNotificationCentre� ���� n   ��� I    �������� 0 cleanup cleanUp��  ��  � o    ���� 	0 kvasd  ��  � ��� l     ��������  ��  ��  � ��� l     ��������  ��  ��  � ��� l     ������  � N H NSDraggingDestination (NSWindow Delgate) Protocol (Not working on 10.7)   � ��� �   N S D r a g g i n g D e s t i n a t i o n   ( N S W i n d o w   D e l g a t e )   P r o t o c o l   ( N o t   w o r k i n g   o n   1 0 . 7 )� ��� l     ��������  ��  ��  � ��� l     ��������  ��  ��  � ��� l     �� ��    ' ! Accept Generic drag&drop sources    � B   A c c e p t   G e n e r i c   d r a g & d r o p   s o u r c e s�  l     ����   %     on draggingEntered_(sender)    � >         o n   d r a g g i n g E n t e r e d _ ( s e n d e r ) 	 l     ��
��  
 A ;        return current application's NSDragOperationGeneric    � v                 r e t u r n   c u r r e n t   a p p l i c a t i o n ' s   N S D r a g O p e r a t i o n G e n e r i c	  l     ����        end draggingEntered_    � 0         e n d   d r a g g i n g E n t e r e d _  l     ��������  ��  ��    l     ����   #  Process a drop on our window    � :   P r o c e s s   a   d r o p   o n   o u r   w i n d o w  l     ����   * $    on performDragOperation_(sender)    � H         o n   p e r f o r m D r a g O p e r a t i o n _ ( s e n d e r )  l     �� !��             try   ! �""                  t r y #$# l     ��%&��  % 9 3            set pb to sender's draggingPasteboard()   & �'' f                         s e t   p b   t o   s e n d e r ' s   d r a g g i n g P a s t e b o a r d ( )$ ()( l     ��*+��  * ] W            if pb's types() as list contains current application's NSURLPboardType then   + �,, �                         i f   p b ' s   t y p e s ( )   a s   l i s t   c o n t a i n s   c u r r e n t   a p p l i c a t i o n ' s   N S U R L P b o a r d T y p e   t h e n) -.- l     ��/0��  / w q                set options to {NSPasteboardURLReadingContentsConformToTypesKey:{"com.apple.application-bundle"}}   0 �11 �                                 s e t   o p t i o n s   t o   { N S P a s t e b o a r d U R L R e a d i n g C o n t e n t s C o n f o r m T o T y p e s K e y : { " c o m . a p p l e . a p p l i c a t i o n - b u n d l e " } }. 232 l     ��45��  4 s m                repeat with u in pb's readObjectsForClasses_options_({current application's |NSURL|},options)   5 �66 �                                 r e p e a t   w i t h   u   i n   p b ' s   r e a d O b j e c t s F o r C l a s s e s _ o p t i o n s _ ( { c u r r e n t   a p p l i c a t i o n ' s   | N S U R L | } , o p t i o n s )3 787 l     ��9:��  9 D >                    copy u's |path| to end of bundlesToProcess   : �;; |                                         c o p y   u ' s   | p a t h |   t o   e n d   o f   b u n d l e s T o P r o c e s s8 <=< l     �>?�  >                   end repeat   ? �@@ 4                                 e n d   r e p e a t= ABA l     �~CD�~  C E ?                if bundlesToProcess � {} and licenceAgreed then   D �EE ~                                 i f   b u n d l e s T o P r o c e s s  "`   { }   a n d   l i c e n c e A g r e e d   t h e nB FGF l     �}HI�}  H ; 5                    installButton's setEnabled_(true)   I �JJ j                                         i n s t a l l B u t t o n ' s   s e t E n a b l e d _ ( t r u e )G KLK l     �|MN�|  M                  end if   N �OO ,                                 e n d   i fL PQP l     �{RS�{  R !                 return true   S �TT 6                                 r e t u r n   t r u eQ UVU l     �zWX�z  W              end if   X �YY $                         e n d   i fV Z[Z l     �y\]�y  \ "         on error errorString   ] �^^ 8                 o n   e r r o r   e r r o r S t r i n g[ _`_ l     �xab�x  a $             abort(errorString)   b �cc <                         a b o r t ( e r r o r S t r i n g )` ded l     �wfg�w  f          end try   g �hh                  e n d   t r ye iji l     �vkl�v  k          return false   l �mm (                 r e t u r n   f a l s ej non l     �upq�u  p #     end performDragOperation_   q �rr :         e n d   p e r f o r m D r a g O p e r a t i o n _o sts l     �t�s�r�t  �s  �r  t uvu l     �q�p�o�q  �p  �o  v wxw l     �nyz�n  y   UI handlers   z �{{    U I   h a n d l e r sx |}| l     �m�l�k�m  �l  �k  } ~~ l     �j�i�h�j  �i  �h   ��� l     �g���g  �  
 Save EULA   � ���    S a v e   E U L A� ��� i   9 <��� I      �f��e�f 0 dosave_ doSave_� ��d� o      �c�c 
0 sender  �d  �e  � Q     $���� n   ��� I    �b�a�`�b 0 savelicense saveLicense�a  �`  � o    �_�_ 	0 kvasd  � R      �^��
�^ .ascrerr ****      � ****� o      �]�] 0 errorstring errorString� �\��[
�\ 
errn� o      �Z�Z 0 errornumber errorNumber�[  � Z    $���Y�� =   ��� o    �X�X 0 errornumber errorNumber� m    �W�W��� l   �V���V  �   just ignore Cancel   � ��� &   j u s t   i g n o r e   C a n c e l�Y  � I    $�U��T�U 	0 abort  � ��S� o     �R�R 0 errorstring errorString�S  �T  � ��� l     �Q�P�O�Q  �P  �O  � ��� l     �N���N  �  
 Save EULA   � ���    S a v e   E U L A� ��� i   = @��� I      �M��L�M 0 doprint_ doPrint_� ��K� o      �J�J 
0 sender  �K  �L  � Q     $���� n   ��� I    �I�H�G�I 0 printlicense printLicense�H  �G  � o    �F�F 	0 kvasd  � R      �E��
�E .ascrerr ****      � ****� o      �D�D 0 errorstring errorString� �C��B
�C 
errn� o      �A�A 0 errornumber errorNumber�B  � Z    $���@�� =   ��� o    �?�? 0 errornumber errorNumber� m    �>�>��� l   �=���=  �   just ignore Cancel   � ��� &   j u s t   i g n o r e   C a n c e l�@  � I    $�<��;�< 	0 abort  � ��:� o     �9�9 0 errorstring errorString�:  �;  � ��� l     �8�7�6�8  �7  �6  � ��� l     �5���5  �   Agree Button handler   � ��� *   A g r e e   B u t t o n   h a n d l e r� ��� i   A D��� I      �4��3�4 0 doagree_ doAgree_� ��2� o      �1�1 
0 sender  �2  �3  � Z     Z���0�/� c     ��� n    	��� I    	�.�-�,�. 	0 state  �-  �,  � o     �+�+ 0 agreecheckbox agreeCheckBox� m   	 
�*
�* 
bool� k    V�� ��� Q    -���� k    �� ��� h    �)��) 0 downloadkvasd downloadKvasd� n    	��� I    	�(�'�&�( 0 fetchbinary fetchBinary�'  �&  � o     �%�% 	0 kvasd  � ��$� n   ��� I    �#��"�# 0 dowithretry doWithRetry� ��!� o    � �  0 downloadkvasd downloadKvasd�!  �"  �  f    �$  � R      ���
� .ascrerr ****      � ****� o      �� 0 errorstring errorString�  � I   ' -���� 	0 abort  � ��� o   ( )�� 0 errorstring errorString�  �  � ��� n  . 8��� I   3 8���� 0 setenabled_ setEnabled_� ��� m   3 4�
� boovfals�  �  � o   . 3�� 0 agreecheckbox agreeCheckBox� ��� r   9 <��� m   9 :�
� boovtrue� o      �� 0 licenceagreed licenceAgreed� ��� Z   = V����� >   = E��� o   = B�� $0 bundlestoprocess bundlesToProcess� J   B D��  � n  H R��� I   M R���� 0 setenabled_ setEnabled_� ��
� m   M N�	
�	 boovtrue�
  �  � o   H M�� 0 installbutton installButton�  �  �  �0  �/  � ��� l     ����  �  �  � ��� l     ����  � #  Choose target button handler   � ��� :   C h o o s e   t a r g e t   b u t t o n   h a n d l e r� ��� i   E H� � I      ��� "0 dochoosetarget_ doChooseTarget_ � o      � �  
0 sender  �  �    Q     a k    X  X    4	��
	 s   % / n   % ( 1   & (��
�� 
psxp o   % &���� 
0 target   n        ;   - . o   ( -���� $0 bundlestoprocess bundlesToProcess�� 
0 target  
 l 	  ���� I   ����
�� .sysostdfalis    ��� null��   ��
�� 
prmp l 	  	���� m    	 � � C h o o s e   t h e   W S J T - X   a p p l i c a t i o n   b u n d l e   y o u   w i s h   t o   i n s t a l l   K V A S D   i n t o��  ��   ��
�� 
ftyp l 	 
 ���� m   
  � 8 c o m . a p p l e . a p p l i c a t i o n - b u n d l e��  ��   ��
�� 
dflc l 
  ���� c     !  c    "#" m    $$ �%%  / A p p l i c a t i o n s# m    ��
�� 
psxf! m    ��
�� 
alis��  ��   ��&'
�� 
lfiv& l 
  (����( m    ��
�� boovfals��  ��  ' ��)��
�� 
mlsl) m    ��
�� boovtrue��  ��  ��   *��* Z   5 X+,����+ F   5 G-.- >   5 =/0/ o   5 :���� $0 bundlestoprocess bundlesToProcess0 J   : <����  . o   @ C���� 0 licenceagreed licenceAgreed, n  J T121 I   O T��3���� 0 setenabled_ setEnabled_3 4��4 m   O P��
�� boovtrue��  ��  2 o   J O���� 0 installbutton installButton��  ��  ��   R      ����5
�� .ascrerr ****      � ****��  5 ��6��
�� 
errn6 d      77 m      ���� ���   l  ` `��89��  8   just ignore Cancel   9 �:: &   j u s t   i g n o r e   C a n c e l� ;<; l     ��������  ��  ��  < =>= l     ��?@��  ?   Install button handler   @ �AA .   I n s t a l l   b u t t o n   h a n d l e r> BCB i   I LDED I      ��F���� 0 
doinstall_ 
doInstall_F G��G o      ���� 
0 sender  ��  ��  E Q     *HIJH k    KK LML I    �������� 0 process  ��  ��  M NON r   	 PQP J   	 ����  Q o      ���� $0 bundlestoprocess bundlesToProcessO R��R n   STS I    ��U���� 0 setenabled_ setEnabled_U V��V m    ��
�� boovfals��  ��  T o    ���� 0 installbutton installButton��  I R      ��W��
�� .ascrerr ****      � ****W o      ���� 0 errorstring errorString��  J I   $ *��X���� 	0 abort  X Y��Y o   % &���� 0 errorstring errorString��  ��  C Z[Z l     ��������  ��  ��  [ \]\ l     ��^_��  ^ < 6 handler called on eulaTextView scroll or view changes   _ �`` l   h a n d l e r   c a l l e d   o n   e u l a T e x t V i e w   s c r o l l   o r   v i e w   c h a n g e s] aba l     ��cd��  c > 8 enables agree/install button once the bottom is reached   d �ee p   e n a b l e s   a g r e e / i n s t a l l   b u t t o n   o n c e   t h e   b o t t o m   i s   r e a c h e db fgf i   M Phih I      ��j���� 0 viewchanged_ viewChanged_j k��k o      ���� 0 anotification aNotification��  ��  i Q     Tlmnl k    Foo pqp r    rsr c    tut n   
vwv o    
���� 
0 bounds  w o    ���� 0 eulatextview eulaTextViewu m   
 ��
�� 
recos o      ���� 0 dr  q xyx r    z{z c    |}| n   ~~ o    ���� 0 visiblerect visibleRect o    ���� 0 eulatextview eulaTextView} m    ��
�� 
reco{ o      ���� 0 vdr  y ���� Z    F������� F    5��� B   .��� \    ,��� n     ��� o     ���� 
0 height  � n    ��� o    ���� 0 size  � o    ���� 0 dr  � l    +������ [     +��� n     %��� o   # %���� 0 y  � n     #��� o   ! #���� 
0 origin  � o     !���� 0 vdr  � n   % *��� o   ( *���� 
0 height  � n   % (��� o   & (���� 0 size  � o   % &���� 0 vdr  ��  ��  � l 
 , -������ m   , -����  ��  ��  � H   1 3�� o   1 2���� 0 licenceagreed licenceAgreed� n  8 B��� I   = B������� 0 setenabled_ setEnabled_� ���� m   = >��
�� boovtrue��  ��  � o   8 =���� 0 agreecheckbox agreeCheckBox��  ��  ��  m R      �����
�� .ascrerr ****      � ****� o      ���� 0 errorstring errorString��  n I   N T������� 	0 abort  � ���� o   O P���� 0 errorstring errorString��  ��  g ��� l     ��������  ��  ��  � ��� l     ������  �    Do something with retries   � ��� 4   D o   s o m e t h i n g   w i t h   r e t r i e s� ��� i   Q T��� I      ������� 0 dowithretry doWithRetry� ���� o      ���� 
0 action  ��  ��  � k     W�� ��� r     ��� m     ��
�� boovfals� o      ���� 0 done  � ���� W    W��� Q   
 R���� k    �� ��� n   ��� I    ������  0 progressaction progressAction� ��~� o    �}�} 
0 action  �~  �  �  f    � ��|� r    ��� m    �{
�{ boovtrue� o      �z�z 0 done  �|  � R      �y��x
�y .ascrerr ****      � ****� o      �w�w 0 errorstring errorString�x  � k    R�� ��� r    "��� m     �v
�v boovfals� o      �u�u 0 usercanceled userCanceled� ��� Q   # C���� r   & 8��� I  & 6�t��
�t .sysodisAaleR        TEXT� o   & '�s�s 0 errorstring errorString� �r��
�r 
as A� l 
 ( )��q�p� m   ( )�o
�o EAlTwarN�q  �p  � �n��
�n 
btns� J   * .�� ��� m   * +�� ���  C a n c e l� ��m� m   + ,�� ��� 
 R e t r y�m  � �l��
�l 
dflt� m   / 0�� ��� 
 R e t r y� �k��j
�k 
cbtn� m   1 2�� ���  C a n c e l�j  � o      �i�i 0 dialogresult dialogResult� R      �h�g�
�h .ascrerr ****      � ****�g  � �f��e
�f 
errn� d      �� m      �d�d ��e  � r   @ C��� m   @ A�c
�c boovtrue� o      �b�b 0 usercanceled userCanceled� ��a� Z   D R���`�_� o   D E�^�^ 0 usercanceled userCanceled� R   H N�]��\
�] .ascrerr ****      � ****� m   J M�� ��� . U s e r   c a n c e l e d   o p e r a t i o n�\  �`  �_  �a  � o    	�[�[ 0 done  ��  � ��� l     �Z�Y�X�Z  �Y  �X  � ��� l     �W���W  � H B execute around handler to display a progress bar during an action   � ��� �   e x e c u t e   a r o u n d   h a n d l e r   t o   d i s p l a y   a   p r o g r e s s   b a r   d u r i n g   a n   a c t i o n� ��� i   U X��� I      �V��U�V  0 progressaction progressAction� ��T� o      �S�S 
0 action  �T  �U  � k      �� � � n    
 I    
�R�Q�R "0 startanimation_ startAnimation_ �P  f    �P  �Q   o     �O�O 0 progressbar progressBar   O    I   �N�M�L
�N .aevtoappnull  �   � ****�M  �L   o    �K�K 
0 action   	�J	 n    

 I     �I�H�I  0 stopanimation_ stopAnimation_ �G  f    �G  �H   o    �F�F 0 progressbar progressBar�J  �  l     �E�D�C�E  �D  �C    l     �B�B     Abort handler    �    A b o r t   h a n d l e r  i   Y \ I      �A�@�A 	0 abort   �? o      �>�> 0 errorstring errorString�?  �@   k       I    �=
�= .sysodisAaleR        TEXT o     �<�< 0 errorstring errorString �; !
�; 
as A  m    �:
�: EAlTcriT! �9"#
�9 
btns" J    $$ %�8% m    && �''  O k�8  # �7(�6
�7 
dflt( m    	)) �**  O k�6   +�5+ I   �4�3�2
�4 .aevtquitnull��� ��� null�3  �2  �5   ,-, l     �1�0�/�1  �0  �/  - ./. l     �.01�.  0   About menu item   1 �22     A b o u t   m e n u   i t e m/ 3�-3 i   ] `454 I      �,6�+�, 0 doabout_ doAbout_6 7�*7 o      �)�) 
0 sender  �*  �+  5 I    �(8�'
�( .sysodisAaleR        TEXT8 m     99 �:: ( K V A S D - i n s t a l l e r   v 1 . 0�'  �-  � ;�&; l     �%�$�#�%  �$  �#  �&       �"<=>?�"  < �!� ��! 0 curl  �  	0 kvasd  � "0 wsjtappdelegate WSJTAppDelegate= � v  @� 0 curl  @  ABCA ��� 0 download  � 0 downloadmd5 downloadMD5B � {��DE�� 0 download  � �F� F  ���� 0 url  � 0 filename fileName� 0 destination  �  D ������ 0 url  � 0 filename fileName� 0 destination  � 0 file  � 0 errorstring errorStringE  � ���� ���

� .sysoexecTEXT���     TEXT� 0 errorstring errorString�  
� 
ret 
�
 
psxf� 4��%E�O �%�%�%�%j W X  )j��%�%�%�%�%�%O��&C �	 ���GH��	 0 downloadmd5 downloadMD5� �I� I  ��� 0 url  � 0 filename fileName�  G ��� ��� 0 url  � 0 filename fileName�  0 md5ext md5Ext�� 0 errorstring errorStringH  � � ������� ���
�� .sysoexecTEXT���     TEXT�� 0 errorstring errorString��  
�� 
ret � 0�E�O �%�%�%�%j W X  )j��%�%�%�%�%�%�%> �� �  J�� 	0 kvasd  J 
 K � �LMNOPQK ������������������ 0 
serverpath 
serverPath�� 0 
targetname 
targetName�� 0 destination  �� 0 	fetcheula 	fetchEULA�� 0 fetchbinary fetchBinary�� 0 savelicense saveLicense�� 0 printlicense printLicense�� 0 cleanup cleanUpL �� �����RS���� 0 destination  ��  ��  R  S ��
�� .fndrgstl****    ��� ****�� �j M ������TU���� 0 	fetcheula 	fetchEULA��  ��  T  U ������ 0 destination  �� 0 download  �� b   b   b  �%)j+ m+ N ������VW���� 0 fetchbinary fetchBinary��  ��  V ���������� 0 url  �� 0 md5sum md5Sum�� 0 file  �� 0 md5calc md5CalcW (*��������M��R����m��prux
�� .sysoexecTEXT���     TEXT�� 0 downloadmd5 downloadMD5�� 0 destination  �� 0 download  
�� 
psxp
�� 
errn���
�� 
ret �� lb   ��%j %E�Ob   �b  l+ E�Ob   �b  )j+ m+ E�O��,%�%j E�O�� )��l��%�%�%�%�%�%�%�%a %Y hO �������XY���� 0 savelicense saveLicense��  ��  X ���� 0 dest  Y �����������������������
�� 
prmp
�� 
dflc
�� afdrdocs
�� .earsffdralis        afdr�� 
�� .sysostflalis    ��� null�� 0 destination  
�� 
psxf
�� 
insh
�� .coreclon****      � ****�� +*����j � E�O� )j+ b  %�%�&�l UP �������Z[���� 0 printlicense printLicense��  ��  Z  [ ���������� 0 destination  
�� 
psxf
�� .aevtpdocnull���     obj �� � )j+ b  %�%�&j UQ �������\]���� 0 cleanup cleanUp��  ��  \  ] ������������� 0 destination  
�� 
psxf
�� .coredoexbool        obj 
�� .coredeloobj        obj �� ]� Y)j+ b  %�%�&j  )j+ b  %�%�&j Y hO)j+ b  %�&j  )j+ b  %�&j Y hU? ���^_�� "0 wsjtappdelegate WSJTAppDelegate^ `` ����a
�� misccura
�� 
pclsa �bb  N S O b j e c t_  c������������������defghijklmnopqrsc ��������������������������������������������������
�� 
pare�� 0 
mainwindow 
mainWindow�� 0 eulatextview eulaTextView�� 0 progressbar progressBar�� 0 
savebutton 
saveButton�� 0 printbutton printButton�� 0 agreecheckbox agreeCheckBox�� (0 choosetargetbutton chooseTargetButton�� 0 installbutton installButton�� $0 bundlestoprocess bundlesToProcess�� 	0 split  �� 0 process  �� B0 applicationwillfinishlaunching_ applicationWillFinishLaunching_�� d0 0applicationshouldterminateafterlastwindowclosed_ 0applicationShouldTerminateAfterLastWindowClosed_�� 60 applicationwillterminate_ applicationWillTerminate_�� 0 dosave_ doSave_�� 0 doprint_ doPrint_�� 0 doagree_ doAgree_�� "0 dochoosetarget_ doChooseTarget_�� 0 
doinstall_ 
doInstall_�� 0 viewchanged_ viewChanged_�� 0 dowithretry doWithRetry��  0 progressaction progressAction�� 	0 abort  �� 0 doabout_ doAbout_��  
�� 
msng
�� 
msng
�� 
msng
�� 
msng
�� 
msng
�� 
msng
�� 
msng
�� 
msngd ������  ��  e ��)����tu���� 	0 split  �� ��v�� v  ������ 0 thetext theText�� 0 thedelimiters theDelimiters��  t ���������� 0 thetext theText�� 0 thedelimiters theDelimiters�� 0 olddelimiters oldDelimiters�� 0 	theresult 	theResultu ������
�� 
ascr
�� 
txdl
�� 
citm�� ��,E�O���,FO��-E�O���,FO�f ��T����wx���� 0 process  ��  ��  w ��~�}�|�{�z�y� 0 
bundlepath 
bundlePath�~ 0 wsjtxbundle wsjtxBundle�} 0 installroot installRoot�| 
0 target  �{ 0 theline theLine�z 0 thedylib theDylib�y 0 errorstring errorStringx ;�x�w�v�u�t�s�r�q�ps�o�n�m�l�k��j���i��h�g�f�e���d��c�b�a�`���_�^��]'.3�\�[�Z�Y�X�WFI�V�UTW
�x 
kocl
�w 
cobj
�v .corecnte****       ****
�u misccura�t 0 nsbundle NSBundle�s "0 bundlewithpath_ bundleWithPath_
�r 
msng�q $0 bundleidentifier bundleIdentifier
�p 
ctxt
�o 
bool
�n 
errn�m�
�l 
ret �k 0 
bundlepath 
bundlePath
�j 
btns
�i 
dflt�h 
�g .sysodlogaskr        TEXT
�f 
rslt
�e 
bhit�d 0 
targetname 
targetName�c 0 destination  
�b 
spac
�a .sysoexecTEXT���     TEXT
�` 
cpar
�_ 
tab �^ 	0 split  
�] .ascrcmnt****      � ****
�\ 
givu�[ �Z 
�Y .sysodisAaleR        TEXT�X 0 errorstring errorString�W  
�V 
as A
�U EAlTwarN����b  	[��l kh  k��,�k+ E�O�� 
 �j+ �&��& )��l��%�%�%�&Y hO�j+ �&E�Oa �%�%�%a a a lva a kva  O_ a ,a   � ٢a %b  a ,%E�Oa b  j+ %b  a ,%_ %�%j  O ma !�%j  a "-[��l kh �a #	 
�a $�& ;*�_ %_ lvl+ &�l/E�Oa '�%a (%*�a )kvl+ &�i/%_ %�%j  Y h[OY��Oa *�%j  j +Oa ,�%�%�%a a -kva a .a /a 0a 1 2W X 3 4)ja 5�%�%�%�%�%a 6%�%Y hW "X 3 4�a 7a 8a a 9kva a :a 1 2[OY�ng �Tg�S�Ryz�Q�T B0 applicationwillfinishlaunching_ applicationWillFinishLaunching_�S �P{�P {  �O�O 0 anotification aNotification�R  y �N�M�L�K�J�N 0 anotification aNotification�M 0 downloadeula downloadEula�L (0 boundschangenotice boundsChangeNotice�K &0 framechangenotice frameChangeNotice�J 0 errorstring errorStringz �I�H�G�F�E�D�C�|�B�A�@�?��>�=�<��;�:�9
�I misccura�H ,0 nsnotificationcenter NSNotificationCenter�G 0 defaultcenter defaultCenter�F 60 defaultnotificationcentre defaultNotificationCentre�E 0 licenceagreed licenceAgreed�D 0 seteditable_ setEditable_�C 0 downloadeula downloadEula| �8}�7�6~�5
�8 .ascrinit****      � ****} k     �� ��4� i     ��� I      �3�2�1
�3 .aevtoappnull  �   � ****�2  �1  � k     �� ��0� l    ��/�.�/  �.  �0  �4  �7  �6  ~ �-
�- .aevtoappnull  �   � **** �� �,��+�*���)
�, .aevtoappnull  �   � ****�+  �*  �  � �(�'�&�( 0 	fetcheula 	fetchEULA
�' .rdwrread****        ****�& 0 
setstring_ 
setString_�) b  b  j+  j k+ �5 L  �B 0 dowithretry doWithRetry�A 0 setenabled_ setEnabled_�@ F0 !nsviewboundsdidchangenotification !NSViewBoundsDidChangeNotification�? D0  nsviewframedidchangenotification  NSViewFrameDidChangeNotification
�> 
msng�= �< F0 !addobserver_selector_name_object_ !addObserver_selector_name_object_�; 0 errorstring errorString�:  �9 	0 abort  �Q q d��,j+ E�OfE�Ob  fk+ O��K S�O)�k+ 	Ob  ek+ 
Ob  ek+ 
O��,E�O��,E�O�)����+ O�)a ���+ W X  *�k+ h �%��$�#���"�% d0 0applicationshouldterminateafterlastwindowclosed_ 0applicationShouldTerminateAfterLastWindowClosed_�$ �!��! �  � �  
0 sender  �#  � �� 
0 sender  �  �" ei �������� 60 applicationwillterminate_ applicationWillTerminate_� ��� �  �� 
0 sender  �  � �� 
0 sender  � ���� 60 defaultnotificationcentre defaultNotificationCentre� "0 removeobserver_ removeObserver_� 0 cleanup cleanUp� �)k+ Ob  j+ j �������� 0 dosave_ doSave_� ��� �  �� 
0 sender  �  � ���� 
0 sender  � 0 errorstring errorString� 0 errornumber errorNumber� ��
��	�� 0 savelicense saveLicense�
 0 errorstring errorString� ���
� 
errn� 0 errornumber errorNumber�  �	��� 	0 abort  � % b  j+  W X  ��  hY *�k+ k �������� 0 doprint_ doPrint_� � ��  �  ���� 
0 sender  �  � �������� 
0 sender  �� 0 errorstring errorString�� 0 errornumber errorNumber� ����������� 0 printlicense printLicense�� 0 errorstring errorString� ������
�� 
errn�� 0 errornumber errorNumber��  ������ 	0 abort  � % b  j+  W X  ��  hY *�k+ l ������������� 0 doagree_ doAgree_�� ����� �  ���� 
0 sender  ��  � �������� 
0 sender  �� 0 downloadkvasd downloadKvasd�� 0 errorstring errorString� ���������������������� 	0 state  
�� 
bool�� 0 downloadkvasd downloadKvasd� �����������
�� .ascrinit****      � ****� k     �� ���� i     ��� I      ������
�� .aevtoappnull  �   � ****��  ��  � k     	�� ���� l    	�������  ��  ��  ��  ��  ��  � ��
�� .aevtoappnull  �   � ****� �� �����������
�� .aevtoappnull  �   � ****��  ��  �  � ���� 0 fetchbinary fetchBinary�� 
b  j+  �� L  �� 0 dowithretry doWithRetry�� 0 errorstring errorString��  �� 	0 abort  �� 0 setenabled_ setEnabled_�� 0 licenceagreed licenceAgreed�� [b  j+  �& M ��K S�O)�k+ W X  *�k+ Ob  fk+ 	OeE�Ob  	jv b  ek+ 	Y hY hm �� ���������� "0 dochoosetarget_ doChooseTarget_�� ����� �  ���� 
0 sender  ��  � ������ 
0 sender  �� 
0 target  � ������$�����������������������������
�� 
prmp
�� 
ftyp
�� 
dflc
�� 
psxf
�� 
alis
�� 
lfiv
�� 
mlsl�� 

�� .sysostdfalis    ��� null
�� 
kocl
�� 
cobj
�� .corecnte****       ****
�� 
psxp�� 0 licenceagreed licenceAgreed
�� 
bool�� 0 setenabled_ setEnabled_��  � ������
�� 
errn������  �� b Z 0*�������&�&�f�e� [��l kh ��,b  	6G[OY��Ob  	jv	 	_ a & b  ek+ Y hW X  hn ��E���������� 0 
doinstall_ 
doInstall_�� ����� �  ���� 
0 sender  ��  � ������ 
0 sender  �� 0 errorstring errorString� ������������ 0 process  �� 0 setenabled_ setEnabled_�� 0 errorstring errorString��  �� 	0 abort  �� + *j+  OjvEc  	Ob  fk+ W X  *�k+ o ��i���������� 0 viewchanged_ viewChanged_�� ����� �  ���� 0 anotification aNotification��  � ���������� 0 anotification aNotification�� 0 dr  �� 0 vdr  �� 0 errorstring errorString� ���������������������������� 
0 bounds  
�� 
reco�� 0 visiblerect visibleRect�� 0 size  �� 
0 height  �� 
0 origin  �� 0 y  �� 0 licenceagreed licenceAgreed
�� 
bool�� 0 setenabled_ setEnabled_�� 0 errorstring errorString��  �� 	0 abort  �� U Hb  �,�&E�Ob  �,�&E�O��,�,��,�,��,�,j	 ��& b  ek+ 	Y hW X 
 *�k+ p ������������� 0 dowithretry doWithRetry�� ����� �  ���� 
0 action  ��  � ������������ 
0 action  �� 0 done  �� 0 errorstring errorString�� 0 usercanceled userCanceled�� 0 dialogresult dialogResult� ��������������������~�}�|����  0 progressaction progressAction�� 0 errorstring errorString��  
�� 
as A
�� EAlTwarN
�� 
btns
�� 
dflt
� 
cbtn�~ 
�} .sysodisAaleR        TEXT�|  � �{�z�y
�{ 
errn�z���y  �� XfE�O Rh� )�k+  OeE�W :X  fE�O ������lv����� E�W 
X  eE�O� )ja Y h[OY��q �x��w�v���u�x  0 progressaction progressAction�w �t��t �  �s�s 
0 action  �v  � �r�r 
0 action  � �q�p�o�q "0 startanimation_ startAnimation_
�p .aevtoappnull  �   � ****�o  0 stopanimation_ stopAnimation_�u !b  )k+  O� *j UOb  )k+ r �n�m�l���k�n 	0 abort  �m �j��j �  �i�i 0 errorstring errorString�l  � �h�h 0 errorstring errorString� 	�g�f�e&�d)�c�b�a
�g 
as A
�f EAlTcriT
�e 
btns
�d 
dflt�c 
�b .sysodisAaleR        TEXT
�a .aevtquitnull��� ��� null�k �����kv��� O*j s �`5�_�^���]�` 0 doabout_ doAbout_�_ �\��\ �  �[�[ 
0 sender  �^  � �Z�Z 
0 sender  � 9�Y
�Y .sysodisAaleR        TEXT�] �j ascr  ��ޭ