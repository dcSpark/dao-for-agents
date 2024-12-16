import { InjectedConnector } from '@web3-react/injected-connector';
import { useWeb3React } from '@web3-react/core';
import { Web3Provider } from '@ethersproject/providers';

export const injected = new InjectedConnector({
  supportedChainIds: [Number(import.meta.env.VITE_CHAIN_ID)]
});

export function useWallet() {
  return useWeb3React<Web3Provider>();
}
