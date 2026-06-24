-- ==============================================================================
-- KINGDOM HEIR — LAUNCH BLOCKERS SCHEMA
-- Generated: 2026-06-16
-- ==============================================================================

-- Start Here Content CMS Table
CREATE TABLE IF NOT EXISTS public.start_here_content (
  content_key TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- RLS
ALTER TABLE public.start_here_content ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access for start here content" ON public.start_here_content FOR SELECT USING (true);
CREATE POLICY "Admins can update start here content" ON public.start_here_content FOR ALL USING (public.is_admin());

-- Seed default content
INSERT INTO public.start_here_content (content_key, title, body) VALUES
(
  'vision_mission',
  'Vision & Mission',
  '{"mission": "Kingdom Heirs Foundation is dedicated to advancing the gospel of Jesus Christ by addressing both the spiritual and practical needs of communities. Through strategic partnerships with local churches, we merge evangelism with humanitarian outreach—bringing freedom, dignity, and hope to those most in need while combating issues like modern slavery.", "vision": "Our vision is to witness cities, nations, and unreached people transformed as the Church unites in compassion, evangelism, and discipleship."}'
),
(
  'founder_letter',
  'A Letter from our Founder',
  'When we launched Kingdom Heirs Foundation, it was with a singular, burning conviction: that the Church is not called to merely exist within four walls, but to dynamically transform the world outside of them.\n\nIn cities around the globe—from the brick kilns of Pakistan to the streets of Texas, from the stadiums of Zambia to the villages of Uganda—we have seen a breathtaking truth unfold. The greatest miracles do not happen when we stand alone. The greatest miracles happen when the body of Christ unites. When pastors pray together, when congregations serve together, and when believers step out in bold faith, the Kingdom of God forcefully advances.\n\nOur mission is simple yet profound: to merge uncompromising evangelism with radical humanitarian outreach. We believe that presenting the hope of the Gospel goes hand-in-hand with restoring dignity, breaking the chains of modern slavery, and feeding the hungry. We are raising up a generation of disciple-makers who are not just attendees, but active participants in the Great Commission.\n\nAs you join us on this journey, my prayer is that you will find your unique place in this movement. Whether you are praying with us, giving to the mission, leading a 90-Day Challenge group, or partnering as a local church, you are a vital part of the Kingdom Heirs family.\n\nTogether, we are making disciples. Together, we are setting captives free. Together, we are building a legacy that will echo into eternity.'
),
(
  'statement_of_faith',
  'Statement of Faith',
  'We believe the Bible to be the inspired, the only infallible, authoritative Word of God.\nWe believe that there is one God, eternally existent in three persons: Father, Son, and Holy Spirit.\nWe believe in the deity of our Lord Jesus Christ, in His virgin birth, in His sinless life, in His miracles, in His vicarious and atoning death through His shed blood, in His bodily resurrection, in His ascension to the right hand of the Father, and in His personal return in power and glory.'
),
(
  'story',
  'Kingdom Heirs Story',
  '{"intro":"The Kingdom Heirs Story began with a simple obedience to God’s call to take the Gospel to the nations. What started as small gatherings has grown into a global movement of believers dedicated to humanitarian outreach, massive stadium crusades, and planting vibrant local churches.", "highlights": [{"title":"Zambia Evangelistic Crusade","date":"September 2025","bullets":["4 nights of Gospel preaching","300 churches involved","80,000+ people in attendance","Over 50,000 decisions for Christ"]}, {"title":"South Africa Gospel Crusade","date":"January 2025","bullets":["70 churches united","Thousands gathered and received Jesus as Lord and Savior","Discipleship program started in multiple churches and schools","Hundreds of students enrolled at initial rollout"]}, {"title":"USA Corpus Christi Texas Thanksgiving Festival","date":"November 2025","bullets":["Multiple Churches United together","300 Turkeys given away","Several $500 Visa gift cards, gas grills, and bikes raffled off","Prayed for Rain with government officials (It rained for 2 weeks after a 3-year drought!)","The Good News was preached and half the crowd responded to the call of salvation","Prayed for the sick and saw many healings with testimonies given"]}, {"title":"Punjab Pakistan Operation Freedom","date":"December 2025","bullets":["Christmas gathering at a Brick Kiln on December 19th","Prepared a warm meal for over 150 people held in slavery including many children","Presented over 100 brand new outfits for the children","Prayed over families and shared a message of hope in Jesus Christ","Saw healings take place—we are one step closer to seeing these families set free"]}, {"title":"Mbale City, Uganda The Gala Cup Tournament","date":"December 2025","bullets":["First ever soccer tournament in Mbale City near the Kenyan border","Focus was Discipleship & Evangelism over 3 days of competition","Over 500 youths attended (half were unchurched) and heard the Gospel","Many made decisions for Jesus, including a Muslim team captain","Partnered with several churches to achieve great success"]}]}'
) ON CONFLICT (content_key) DO NOTHING;
