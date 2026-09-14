'use client'

import { useState } from 'react';

type ProbeState =
    | { status: 'idle' }
    | { status: 'loading' }
    | { status: 'success'; message: string }
    | { status: 'error'; message: string };

export default function ApiProbe() {
    const [state, setState] = useState<ProbeState>({ status: 'idle' });

    async function runProbe() {
        setState({ status: 'loading' });

        try {
            const response = await fetch("/api/dev-probe");

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}`);
            }

            const data = (await response.json()) as { message: string };

            setState({
                status: 'success',
                message: data.message ?? 'API probe succeeded',
            });
        } catch (error) {
            setState({
                status: 'error',
                message:
                    error instanceof Error
                        ? error.message
                        : 'API probe failed',
            })
        }
    }

    return (
        <section>
            <button type="button" onClick={runProbe}>
                Run API Probe
            </button>

            {state.status === 'loading' && <p>Checking API...</p>}

            {state.status === 'success' && <p>{state.message}</p>}

            {state.status === 'error' && <p>API probe failed: {state.message}</p>}
        </section>
    );
}
