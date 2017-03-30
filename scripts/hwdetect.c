/* hwdetect.c - module for detecting hardware */
/*
 *  GRUB  --  GRand Unified Bootloader
 *  Copyright (C) 2003,2007  Free Software Foundation, Inc.
 *  Copyright (C) 2003  NIIBE Yutaka <gniibe@m17n.org>
 *
 *  GRUB is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  GRUB is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with GRUB.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <grub/dl.h>
#include <grub/env.h>
#include <grub/err.h>
#include <grub/extcmd.h>
#include <grub/i18n.h>
#include <grub/misc.h>
#include <grub/mm.h>
#include <grub/pci.h>
#include <grub/types.h>

GRUB_MOD_LICENSE ("GPLv3+");

static int intel_hd_graphics_3000 = 0;
static int amd_radeon_hd_6600M_series = 0;

static int
grub_hwdetect_iter (grub_pci_device_t dev __attribute__ ((unused)), grub_pci_id_t pciid,
		 void *data __attribute__ ((unused)))
{
  // for getting the numerical PCI ID we have to swap the parts of the hex representation
  // e.g. "8086:0116" -> 0x01168086 = 18251910

  switch(pciid) {
    case 18251910:
      // PCI ID "8086:0116"
      intel_hd_graphics_3000=1;
      break;

    case 1732317186:
      // PCI ID "1002:6741"
      amd_radeon_hd_6600M_series=1;
      break;
  }

  return 0;
}

static grub_err_t
grub_cmd_hwdetect (grub_extcmd_context_t ctxt __attribute__ ((unused)),
		int argc __attribute__ ((unused)),
		char **args __attribute__ ((unused)))
{
  grub_pci_iterate (grub_hwdetect_iter, NULL);
  if (intel_hd_graphics_3000 && amd_radeon_hd_6600M_series) {
    grub_env_set ("detected_hw", "Mac_A1286");
  } else {
    grub_env_set ("detected_hw", "unknown");
  }
  return 0;
}

static grub_extcmd_t cmd;

GRUB_MOD_INIT(hwdetect)
{
  cmd = grub_register_extcmd ("hwdetect", grub_cmd_hwdetect, 0, 0,
			      N_("Detects hardware and sets the 'detected_hw' variable."), 0);
}

GRUB_MOD_FINI(hwdetect)
{
  grub_unregister_extcmd (cmd);
}
