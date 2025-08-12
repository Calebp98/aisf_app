import { supabase } from './supabase.js'

// Auth state management
let currentUser = null
let currentProfile = null
let authListeners = []

// Initialize auth state
export async function initAuth() {
  // Get initial session
  const { data: { session }, error } = await supabase.auth.getSession()
  if (session) {
    await setCurrentUser(session.user)
  }
  
  // Listen for auth changes
  supabase.auth.onAuthStateChange(async (event, session) => {
    if (event === 'SIGNED_IN' && session) {
      await setCurrentUser(session.user)
    } else if (event === 'SIGNED_OUT') {
      currentUser = null
      currentProfile = null
    }
    
    // Notify listeners
    authListeners.forEach(listener => listener(currentUser, currentProfile))
  })
}

// Set current user and fetch profile
async function setCurrentUser(user) {
  currentUser = user
  
  if (user) {
    try {
      // First try to fetch existing profile
      const { data: profile, error } = await supabase
        .from('users')
        .select('*')
        .eq('auth_user_id', user.id)
        .single()
      
      if (error || !profile) {
        // Profile doesn't exist, create it
        const { data: newProfile, error: insertError } = await supabase
          .from('users')
          .insert({
            auth_user_id: user.id,
            email: user.email,
            name: user.user_metadata?.name || user.email.split('@')[0],
            title: user.user_metadata?.title || '',
            company: user.user_metadata?.company || '',
            bio: user.user_metadata?.bio || '',
            interests: user.user_metadata?.interests || []
          })
          .select()
          .single()
        
        if (!insertError && newProfile) {
          currentProfile = newProfile
        } else {
          console.error('Profile creation error:', insertError)
          // Create a fallback profile object
          currentProfile = {
            id: null,
            auth_user_id: user.id,
            email: user.email,
            name: user.email.split('@')[0],
            title: '',
            company: ''
          }
        }
      } else {
        currentProfile = profile
      }
    } catch (err) {
      console.error('Error with user profile:', err)
      // Create fallback profile
      currentProfile = {
        id: null,
        auth_user_id: user.id,
        email: user.email,
        name: user.email.split('@')[0],
        title: '',
        company: ''
      }
    }
  }
}

// Auth functions
export async function signUp(email, password, userData = {}) {
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: userData
    }
  })
  
  return { data, error }
}

export async function signIn(email, password) {
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password
  })
  
  return { data, error }
}

export async function signOut() {
  const { error } = await supabase.auth.signOut()
  return { error }
}

// Getters
export function getCurrentUser() {
  return currentUser
}

export function getCurrentProfile() {
  return currentProfile
}

export function isAuthenticated() {
  return !!currentUser
}

// Listen for auth state changes
export function onAuthStateChange(callback) {
  authListeners.push(callback)
  
  // Return unsubscribe function
  return () => {
    const index = authListeners.indexOf(callback)
    if (index > -1) {
      authListeners.splice(index, 1)
    }
  }
}

// RSVP functions (user-specific)
export async function toggleRSVP(sessionId) {
  if (!isAuthenticated() || !currentProfile) {
    throw new Error('Must be logged in to RSVP')
  }
  
  // Check if user already has an RSVP
  const { data: existing } = await supabase
    .from('session_rsvps')
    .select('*')
    .eq('session_id', sessionId)
    .eq('user_id', currentProfile.id)
    .single()
  
  if (existing) {
    // Remove RSVP
    const { error } = await supabase
      .from('session_rsvps')
      .delete()
      .eq('id', existing.id)
    
    return { isRSVPed: false, error }
  } else {
    // Add RSVP
    const { error } = await supabase
      .from('session_rsvps')
      .insert({
        session_id: sessionId,
        user_id: currentProfile.id,
        status: 'going'
      })
    
    return { isRSVPed: true, error }
  }
}

// Get user's RSVPs
export async function getUserRSVPs() {
  if (!isAuthenticated() || !currentProfile) {
    return []
  }
  
  const { data, error } = await supabase
    .from('session_rsvps')
    .select(`
      *,
      sessions (*)
    `)
    .eq('user_id', currentProfile.id)
    .eq('status', 'going')
  
  return data || []
}

// Check if user has RSVPed to specific sessions
export async function getUserRSVPStatus(sessionIds) {
  if (!isAuthenticated() || !currentProfile) {
    return {}
  }
  
  const { data } = await supabase
    .from('session_rsvps')
    .select('session_id')
    .eq('user_id', currentProfile.id)
    .in('session_id', sessionIds)
  
  const rsvpMap = {}
  data?.forEach(rsvp => {
    rsvpMap[rsvp.session_id] = true
  })
  
  return rsvpMap
}

// Send a message (authenticated)
export async function sendMessage(channelId, content) {
  if (!isAuthenticated() || !currentProfile) {
    throw new Error('Must be logged in to send messages')
  }
  
  // Handle case where profile doesn't have an ID (fallback profile)
  const senderId = currentProfile.id || null
  const senderName = currentProfile.name || currentUser.email.split('@')[0]
  
  const { error } = await supabase
    .from('messages')
    .insert({
      channel_id: channelId,
      sender_id: senderId,
      sender_name: senderName,
      content
    })
  
  return { error }
}