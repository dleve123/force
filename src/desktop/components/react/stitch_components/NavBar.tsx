import React from "react"
import styled from "styled-components"
import { NavBar as ReactionNavBar } from "reaction/Components/NavBar"
import { FlashBanner } from "reaction/Components/FlashBanner"
import { data as sd } from "sharify"

import {
  SystemContextProvider,
  SystemContextProps,
} from "@artsy/reaction/dist/Artsy"
import { StagingBanner } from "./StagingBanner"

const mediator = require("desktop/lib/mediator.coffee")

const NavBarContainer = styled.div`
  z-index: 990;
  width: 100%;
  top: 0;
  left: 0;

  /* FIXME: Overwrite main force navbar style. Once main bar is totally removed
     and no longer controlled by an ENV var we can remove this. */
  border-bottom: none !important;
`

interface NavBarProps {
  user: SystemContextProps["user"]
  notificationCount: number
  searchQuery?: string
  flashMessage?: string
}

export const NavBar: React.FC<NavBarProps> = ({
  flashMessage,
  notificationCount,
  searchQuery,
  user,
}) => {
  const showStagingBanner = sd.APPLICATION_NAME === "force-staging"
  return (
    <SystemContextProvider
      mediator={mediator}
      notificationCount={notificationCount}
      searchQuery={searchQuery}
      user={user}
    >
      <NavBarContainer id="main-layout-header">
        {showStagingBanner && <StagingBanner />}
        <ReactionNavBar />
        {<FlashBanner messageCode={flashMessage} />}
      </NavBarContainer>
    </SystemContextProvider>
  )
}
