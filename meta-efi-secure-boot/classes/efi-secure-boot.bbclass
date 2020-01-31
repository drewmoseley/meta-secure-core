#
# This class implements signing for images that
# automatically generate components in do_bootimg.
# Notably hddimg.
#
# This should be added to your build using:
#     IMAGE_CLASSES_append = " efi-secure-boot "
#

inherit ${@'user-key-store' if d.getVar('GRUB_SIGN_VERIFY') == '1' else ''}

def sign_file_and_deploy(d, hdddir, dirname, basename):
    filename = "%s%s/%s" % (hdddir, dirname, basename)

    if bb.utils.contains("DISTRO_FEATURES", "efi-secure-boot", "True", "False", d) and \
       d.getVar('GRUB_SIGN_VERIFY') == '1' and \
       os.path.exists(filename):

        uks_bl_sign(filename, d)

        imgfile = "%s/%s.hddimg" % (d.getVar("IMGDEPLOYDIR"), d.getVar("IMAGE_NAME"))
        signed_filename = "%s%s" % (filename, d.getVar("SB_FILE_EXT"))
        target_directory = "::%s/" % dirname
        cmd = "mcopy -i %s %s %s" % (imgfile, signed_filename, target_directory)
        try:
            result,_ = bb.process.run(cmd)
        except bb.process.ExecutionError:
            bb.fatal('Unable to copy signature for %s to hddimg' % filename)

do_bootimg_append() {
    sign_file_and_deploy(d, d.getVar("HDDDIR"), d.getVar("EFIDIR"), "grub.cfg")
    sign_file_and_deploy(d, d.getVar("HDDDIR"), "/", d.getVar("KERNEL_IMAGETYPE"))
    sign_file_and_deploy(d, d.getVar("HDDDIR"), "/", "initrd")
}
do_bootimg[prefuncs] += " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'efi-secure-boot', 'check_deploy_keys', '', d)} \
    ${@'check_boot_public_key' if d.getVar('GRUB_SIGN_VERIFY') == '1' else ''} \
"
