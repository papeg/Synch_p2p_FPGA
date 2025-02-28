MPI1_FOLDER := PRK/MPI1/Synch_p2p
MPI1_BIN := $(MPI1_FOLDER)/p2p

MPIRMA_FOLDER := PRK/MPIRMA/Synch_p2p
MPIRMA_BIN := $(MPIRMA_FOLDER)/p2p

MPISHM_FOLDER := PRK/MPISHM/Synch_p2p
MPISHM_BIN := $(MPISHM_FOLDER)/p2p

.PHONY:all
all: PRK PRK/common/make.defs $(MPI1_BIN) $(MPIRMA_BIN) $(MPISHM_BIN)

PRK:
	git submodule init --update

PRK/common/make.defs:
	cp make.defs PRK/common/

$(MPI1_BIN):
	make -C $(MPI1_FOLDER) p2p

$(MPIRMA_BIN):
	make -C $(MPIRMA_FOLDER) p2p

$(MPISHM_BIN):
	make -C $(MPISHM_FOLDER) p2p

.PHONY: clean
clean:
	rm -f $(MPI1_BIN)
	rm -f $(MPI1_FOLDER)/*.o
	rm -f $(MPIRMA_BIN)
	rm -f $(MPIRMA_FOLDER)/*.o
	rm -f $(MPISHM_BIN)
	rm -f $(MPISHM_FOLDER)/*.o
