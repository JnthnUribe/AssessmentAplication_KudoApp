import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { BrowserRouter, Routes, Route } from 'react-router-dom'
import './index.css'
import IntroductionScreen from './components/layout/body/introductionscreen/IntroductionScreen.jsx'
import AuthenticationScreen from './components/layout/body/introductionscreen/authenticationscreen/AuthenticationScreen.jsx'
import Dashboard from './components/layout/body/dashboard/Dashboard.jsx'

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<IntroductionScreen />} />
        <Route path="/login" element={<AuthenticationScreen />} />
        <Route path="/dashboard" element={<Dashboard />} />
      </Routes>
    </BrowserRouter>
  </StrictMode>,
)
